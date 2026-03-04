<#
.SYNOPSIS
    Consolidate memory candidates into a reviewed report and promotion file.

.DESCRIPTION
    Reads all candidate .md files from memory/candidates/YYYY-MM-DD/, reads
    today's daily log, deduplicates entries, flags conflicts, produces an audit
    report in memory/reports/, and writes promoted items to memory/promotions/
    for human review.

    IMPORTANT: This script NEVER writes to MEMORY.md directly.
    Human approval is required before any promotions are merged into MEMORY.md.

.PARAMETER Date
    (Optional) Target date in YYYY-MM-DD format. Defaults to today.

.PARAMETER CandidateDate
    (Optional) Date of the candidates folder to process. Defaults to -Date.

.PARAMETER WorkspaceRoot
    (Optional) Workspace root directory. Defaults to the parent-parent of this
    script's directory, so the script works from Creator workspace OR shared/scripts/.
    Override to point at any agent's workspace root.

.EXAMPLE
    # Process today's candidates
    .\consolidate.ps1

.EXAMPLE
    # Process a specific date
    .\consolidate.ps1 -Date "2026-03-02"

.EXAMPLE
    # Run from shared/scripts/ against a specific workspace
    .\consolidate.ps1 -WorkspaceRoot "C:\Users\azureuser\.openclaw-creator\workspace"

.NOTES
    Conflict detection: if two candidates share the same heading line but have
    different body content, they are flagged with a WARNING: CONFLICT prefix.

    Deduplication: entries already present in MEMORY.md (substring match) are
    skipped. Duplicate candidates (identical heading + body) are collapsed to one.
#>

param(
    [Parameter(Mandatory = $false)]
    [string]$Date = (Get-Date -Format "yyyy-MM-dd"),

    [Parameter(Mandatory = $false)]
    [string]$CandidateDate = "",

    [Parameter(Mandatory = $false)]
    [string]$WorkspaceRoot = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ---- Resolve workspace root --------------------------------------------------
# If not provided, derive from script location (works from workspace or shared/scripts/)
if ([string]::IsNullOrWhiteSpace($WorkspaceRoot)) {
    $WorkspaceRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
}

# ---- Paths -------------------------------------------------------------------
$memoryRoot     = Join-Path $WorkspaceRoot "memory"
$candidatesRoot = Join-Path $memoryRoot "candidates"
$reportsDir     = Join-Path $memoryRoot "reports"
$promotionsDir  = Join-Path $memoryRoot "promotions"
$memoryMd       = Join-Path $WorkspaceRoot "MEMORY.md"

if ([string]::IsNullOrWhiteSpace($CandidateDate)) { $CandidateDate = $Date }

$candidateFolder = Join-Path $candidatesRoot $CandidateDate
$dailyLog        = Join-Path $memoryRoot "$Date.md"
$reportPath      = Join-Path $reportsDir  "${Date}--consolidation.md"
$promotionPath   = Join-Path $promotionsDir "${Date}--promoted.md"

# Ensure output dirs exist
New-Item -ItemType Directory -Path $reportsDir   -Force | Out-Null
New-Item -ItemType Directory -Path $promotionsDir -Force | Out-Null

Write-Host ""
Write-Host "=========================================="
Write-Host " Memory Consolidation: $Date"
Write-Host "=========================================="

# ---- Load MEMORY.md for skip-check ------------------------------------------
$memoryMdContent = ""
if (Test-Path $memoryMd) {
    $memoryMdContent = (Get-Content $memoryMd -Raw -Encoding UTF8).TrimStart([char]0xFEFF)
} else {
    Write-Host "[WARN] MEMORY.md not found at $memoryMd -- skip-check disabled."
}

# ---- Helper: parse a .md file into a list of entry hashtables ---------------
# Each entry: @{ Heading = "..."; Body = "..."; SourceFile = "..." }
# Entries are delimited by lines that start with "## "
function Parse-Entries {
    param([string]$text, [string]$sourceFile = "")
    # Strip UTF-8 BOM (U+FEFF) that may appear at the start of BOM-prefixed files
    $text = $text -replace '^\xEF\xBB\xBF', ''   # raw BOM bytes (if read as Latin-1)
    $text = $text.TrimStart([char]0xFEFF)          # Unicode BOM char (if read as UTF-16/UTF-8)
    $entries = @()
    $blocks = [regex]::Split($text, '(?m)(?=^## )')
    foreach ($block in $blocks) {
        $trimmed = $block.Trim()
        if ([string]::IsNullOrWhiteSpace($trimmed)) { continue }
        $lines   = $trimmed -split "`n"
        $heading = $lines[0].Trim().TrimStart([char]0xFEFF)   # belt-and-suspenders per-line BOM strip
        # Guard: when there is only 1 line, $lines[1..0] in PowerShell reverses the array.
        # Use explicit length check to avoid IndexOutOfRangeException and reverse-slice bug.
        if ($lines.Length -gt 1) {
            $body = ($lines[1..($lines.Length - 1)] -join "`n").Trim()
        } else {
            $body = ""
        }
        $entry   = @{ Heading = $heading; Body = $body; SourceFile = $sourceFile }
        $entries += $entry
    }
    # Wrap in @() to guarantee array return even with 0 or 1 entries
    return @($entries)
}

# ---- Collect candidate files -------------------------------------------------
$candidateFiles = @()
if (Test-Path $candidateFolder) {
    $candidateFiles = @(Get-ChildItem -Path $candidateFolder -Filter "*.md" -File |
                      Where-Object { $_.Name -ne "README.md" } |
                      Sort-Object Name)
}

Write-Host "Candidate folder : $candidateFolder"
Write-Host "Candidate files  : $($candidateFiles.Count)"

# ---- Parse daily log ---------------------------------------------------------
$dailyEntries = @()
if (Test-Path $dailyLog) {
    $dailyText    = Get-Content $dailyLog -Raw -Encoding UTF8
    $dailyEntries = @(Parse-Entries -text $dailyText -sourceFile "daily-log")
    Write-Host "Daily log entries: $($dailyEntries.Count) (from $dailyLog)"
} else {
    Write-Host "Daily log        : not found ($dailyLog) -- skipping"
}

# ---- Parse all candidate files -----------------------------------------------
$allCandidateEntries = @()
foreach ($file in $candidateFiles) {
    $text    = Get-Content $file.FullName -Raw -Encoding UTF8
    $entries = @(Parse-Entries -text $text -sourceFile $file.Name)
    $allCandidateEntries += $entries
}

# Combine candidates + daily log entries
$allEntries      = @($allCandidateEntries) + @($dailyEntries)
$totalCandidates = $allEntries.Count
Write-Host "Total entries    : $totalCandidates"
Write-Host ""

# ---- Deduplication + conflict detection -------------------------------------
# Group by heading (lowercase, trimmed)
$grouped = @{}
foreach ($e in $allEntries) {
    $key = $e.Heading.ToLower().Trim()
    if (-not $grouped.ContainsKey($key)) {
        $grouped[$key] = [System.Collections.ArrayList]@()
    }
    [void]$grouped[$key].Add($e)
}

$promoted  = [System.Collections.ArrayList]@()
$conflicts = [System.Collections.ArrayList]@()
$skipped   = [System.Collections.ArrayList]@()

foreach ($key in $grouped.Keys) {
    $group = $grouped[$key]

    # Representative heading (first occurrence)
    $heading = $group[0].Heading

    # Unique bodies (trimmed) -- wrap in @() to guarantee array even with 1 item
    $uniqueBodies = @($group | ForEach-Object { $_.Body.Trim() } | Sort-Object -Unique)

    if ($uniqueBodies.Count -gt 1) {
        # CONFLICT: same heading, different bodies
        $cb  = "## WARNING: CONFLICT -- $heading`n`n"
        $idx = 1
        foreach ($b in $uniqueBodies) {
            $cb += "**Variant ${idx}:**`n$b`n`n"
            $idx++
        }
        [void]$conflicts.Add($cb.Trim())
    } else {
        # Single unique body -- check if already in MEMORY.md
        $body = $uniqueBodies[0]

        # Strip "## " prefix from heading for a cleaner substring check
        $headingText = $heading -replace '^##\s*', ''

        $headingInMemory = $memoryMdContent.IndexOf($headingText, [System.StringComparison]::OrdinalIgnoreCase) -ge 0
        $bodyInMemory    = (-not [string]::IsNullOrWhiteSpace($body)) -and ($memoryMdContent.IndexOf($body.Trim(), [System.StringComparison]::OrdinalIgnoreCase) -ge 0)

        if ($headingInMemory -or $bodyInMemory) {
            [void]$skipped.Add(@{ Heading = $heading; Body = $body })
        } else {
            [void]$promoted.Add(@{ Heading = $heading; Body = $body })
        }
    }
}

$promotedCount = $promoted.Count
$conflictCount = $conflicts.Count
$skippedCount  = $skipped.Count

# ---- Build consolidation report ---------------------------------------------
$runTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC"

$reportLines = [System.Collections.ArrayList]@()
[void]$reportLines.Add("# Memory Consolidation Report -- $Date")
[void]$reportLines.Add("")
[void]$reportLines.Add("**Run:** $runTime")
[void]$reportLines.Add("**Candidate folder:** ``$candidateFolder``")
[void]$reportLines.Add("**Candidate files processed:** $($candidateFiles.Count)")
[void]$reportLines.Add("**Daily log entries:** $($dailyEntries.Count)")
[void]$reportLines.Add("")
[void]$reportLines.Add("## Summary")
[void]$reportLines.Add("")
[void]$reportLines.Add("| Metric | Count |")
[void]$reportLines.Add("|--------|-------|")
[void]$reportLines.Add("| Total candidates | $totalCandidates |")
[void]$reportLines.Add("| Promoted (new, non-conflicting) | $promotedCount |")
[void]$reportLines.Add("| Conflicts flagged | $conflictCount |")
[void]$reportLines.Add("| Skipped (already in MEMORY.md) | $skippedCount |")
[void]$reportLines.Add("")

if ($conflicts.Count -gt 0) {
    [void]$reportLines.Add("---")
    [void]$reportLines.Add("")
    [void]$reportLines.Add("## WARNING: Conflicts (require manual resolution)")
    [void]$reportLines.Add("")
    [void]$reportLines.Add("> These items have the same heading but different body content.")
    [void]$reportLines.Add("> Resolve manually before promoting to MEMORY.md.")
    [void]$reportLines.Add("")
    foreach ($c in $conflicts) {
        [void]$reportLines.Add($c)
        [void]$reportLines.Add("")
    }
}

if ($skipped.Count -gt 0) {
    [void]$reportLines.Add("---")
    [void]$reportLines.Add("")
    [void]$reportLines.Add("## Skipped (already in MEMORY.md)")
    [void]$reportLines.Add("")
    foreach ($s in $skipped) {
        [void]$reportLines.Add("- $($s.Heading)")
    }
    [void]$reportLines.Add("")
}

if ($promoted.Count -gt 0) {
    [void]$reportLines.Add("---")
    [void]$reportLines.Add("")
    [void]$reportLines.Add("## Promoted Items (pending human approval)")
    [void]$reportLines.Add("")
    [void]$reportLines.Add("> See memory/promotions/${Date}--promoted.md for the full content.")
    [void]$reportLines.Add("> Xiaosong or Admin must approve before merging to MEMORY.md.")
    [void]$reportLines.Add("")
    foreach ($p in $promoted) {
        [void]$reportLines.Add("- $($p.Heading)")
    }
    [void]$reportLines.Add("")
}

$reportContent = $reportLines -join "`n"
Set-Content -Path $reportPath -Value $reportContent -Encoding UTF8
Write-Host "Report written   : $reportPath"

# ---- Build promotions file ---------------------------------------------------
if ($promoted.Count -gt 0) {
    $promLines = [System.Collections.ArrayList]@()
    [void]$promLines.Add("# Promotions Pending Review -- $Date")
    [void]$promLines.Add("")
    [void]$promLines.Add("> **Action required:** Xiaosong or Admin must review and approve.")
    [void]$promLines.Add("> Copy approved items manually to MEMORY.md. Do NOT auto-merge.")
    [void]$promLines.Add("> Generated by: memory/scripts/consolidate.ps1")
    [void]$promLines.Add("")
    [void]$promLines.Add("---")
    [void]$promLines.Add("")

    foreach ($p in $promoted) {
        [void]$promLines.Add($p.Heading)
        [void]$promLines.Add("")
        if (-not [string]::IsNullOrWhiteSpace($p.Body)) {
            [void]$promLines.Add($p.Body)
        }
        [void]$promLines.Add("")
        [void]$promLines.Add("---")
        [void]$promLines.Add("")
    }

    $promContent = $promLines -join "`n"
    Set-Content -Path $promotionPath -Value $promContent -Encoding UTF8
    Write-Host "Promotions written: $promotionPath"
} else {
    Write-Host "Promotions       : none (nothing new to promote)"
}

# ---- Print summary -----------------------------------------------------------
Write-Host ""
Write-Host "=========================================="
Write-Host " Consolidation complete"
Write-Host "=========================================="
Write-Host "  Candidates : $totalCandidates"
Write-Host "  Promoted   : $promotedCount"
Write-Host "  Conflicts  : $conflictCount"
Write-Host "  Skipped    : $skippedCount"
Write-Host ""
Write-Host "Next step: review $reportPath"
if ($promotedCount -gt 0) {
    Write-Host "Then approve   : $promotionPath"
}
Write-Host ""
