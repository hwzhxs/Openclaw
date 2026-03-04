<#
.SYNOPSIS
    Extract a memory candidate and write it to the candidates folder.

.DESCRIPTION
    Writes a single memory insight/fact/decision as a timestamped Markdown file
    to memory/candidates/YYYY-MM-DD/. Safe for concurrent writes — uses a random
    4-char suffix to prevent filename collisions.

    Output includes `learned_at` and `source` fields required by D3.1/D3.2.

.PARAMETER Content
    The insight, fact, or decision to record.

.PARAMETER Category
    Category label (e.g. "Decision", "Insight", "Config", "Pattern", "Error").

.PARAMETER Source
    Who/what produced this entry (e.g. "Creator", "Thinker", "heartbeat-check").

.PARAMETER ThreadId
    (Optional) Slack thread timestamp or file path that is the source of this fact.
    Used to populate the `source` metadata field for traceability.

.PARAMETER WorkspaceRoot
    (Optional) Workspace root directory. Defaults to the parent-parent of this
    script's directory (resolves correctly whether run from Creator workspace or
    shared/scripts/). Can be overridden for any agent workspace.

.EXAMPLE
    .\extract-candidate.ps1 -Content "Always test live URLs before marking done." -Category "Rule" -Source "Creator"

.EXAMPLE
    .\extract-candidate.ps1 -Content "Deploy decision locked." -Category "Decision" -Source "Admin" -ThreadId "1772418675.684739"

.NOTES
    - NEVER write directly to MEMORY.md or TEAM-MEMORY.md
    - This script is the only sanctioned way for agents to write memory candidates
    - Output files are append-only; never edit them after writing
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Content,

    [Parameter(Mandatory = $true)]
    [string]$Category,

    [Parameter(Mandatory = $true)]
    [string]$Source,

    [Parameter(Mandatory = $false)]
    [string]$ThreadId = "",

    [Parameter(Mandatory = $false)]
    [string]$WorkspaceRoot = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ── Resolve workspace root ───────────────────────────────────────────────────
# If not provided, derive from script location:
#   memory/scripts/extract-candidate.ps1  → workspace = $PSScriptRoot\..\..\
# This works whether the script lives in Creator workspace OR shared/scripts/.
if ([string]::IsNullOrWhiteSpace($WorkspaceRoot)) {
    $WorkspaceRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
}

$candidatesRoot = Join-Path $WorkspaceRoot "memory\candidates"

# ── Date/time ────────────────────────────────────────────────────────────────
$now           = (Get-Date).ToUniversalTime()
$dateStr       = $now.ToString("yyyy-MM-dd")
$timeStamp     = $now.ToString("yyyyMMdd-HHmmss")
$learnedAt     = $now.ToString("yyyy-MM-ddTHH:mm:ssZ")

# ── Unique random suffix (4 hex chars) to prevent collisions ─────────────────
$rand4 = -join ((1..4) | ForEach-Object { '{0:X}' -f (Get-Random -Minimum 0 -Maximum 16) })

# ── Ensure daily folder exists ────────────────────────────────────────────────
$dailyFolder = Join-Path $candidatesRoot $dateStr
if (-not (Test-Path $dailyFolder)) {
    New-Item -ItemType Directory -Path $dailyFolder -Force | Out-Null
}

# ── Build filename ────────────────────────────────────────────────────────────
$filename = "$timeStamp-$rand4.md"
$filePath = Join-Path $dailyFolder $filename

# ── Resolve source field ──────────────────────────────────────────────────────
$sourceField = if ([string]::IsNullOrWhiteSpace($ThreadId)) { $Source } else { "$Source | thread:$ThreadId" }

# ── Build file content ────────────────────────────────────────────────────────
$fileContent = @"
## [$Category] Source: $Source

learned_at: $learnedAt
source: $sourceField

$Content
"@

# ── Write (no overwrite — this is a new unique file) ─────────────────────────
Set-Content -Path $filePath -Value $fileContent -Encoding UTF8 -NoNewline:$false

Write-Host "Candidate written: $filePath"
