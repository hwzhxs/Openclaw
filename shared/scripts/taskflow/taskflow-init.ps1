#Requires -Version 5.1
<#
.SYNOPSIS
    Taskflow OS - Database Initialiser
    Creates (or migrates) the SQLite database and all tables.

.DESCRIPTION
    Uses PSSQLite module (available on this VM).
    Falls back to a JSON file store if PSSQLite is unavailable.

.USAGE
    # First-time setup:
    .\taskflow-init.ps1

    # Force-reset (drops and recreates all tables):
    .\taskflow-init.ps1 -Force

    # Use a custom config path:
    .\taskflow-init.ps1 -ConfigPath "D:\myconfig.json"
#>

[CmdletBinding()]
param(
    [string]$ConfigPath  = "$PSScriptRoot\taskflow-config.json",
    [switch]$Force,
    [switch]$JsonFallback
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Load L0 module
# ---------------------------------------------------------------------------
$l0Path = Join-Path $PSScriptRoot "taskflow-l0.ps1"
if (-not (Test-Path $l0Path)) { throw "L0 module not found: $l0Path" }
. $l0Path

$cfg = Get-TFConfig -ConfigPath $ConfigPath
Write-Host "[INIT] Taskflow DB initialiser starting..." -ForegroundColor Cyan
Write-Host "[INIT] dry_run=$($cfg.dry_run)  enabled=$($cfg.enabled)"

# ---------------------------------------------------------------------------
# Determine storage backend
# ---------------------------------------------------------------------------
$usePSSQLite = $false
$useJsonFallback = $false

if ($JsonFallback) {
    $useJsonFallback = $true
    Write-Host "[INIT] JSON fallback forced by -JsonFallback switch."
} else {
    try {
        Import-Module PSSQLite -ErrorAction Stop
        $usePSSQLite = $true
        Write-Host "[INIT] PSSQLite module loaded OK." -ForegroundColor Green
    }
    catch {
        Write-Warning "PSSQLite not available: $_"
        Write-Warning "Falling back to JSON file store."
        $useJsonFallback = $true
    }
}

# ---------------------------------------------------------------------------
# SQLite path
# ---------------------------------------------------------------------------
$dbPath     = $cfg.storage.sqlite_path
$jsonPath   = $cfg.storage.fallback_json_path
$schemaPath = Join-Path $PSScriptRoot "taskflow-schema.sql"

# ---------------------------------------------------------------------------
# Helper: execute SQL statements via raw ADO.NET connection
# (PSSQLite's Invoke-SqliteQuery wraps results in a DataSet and chokes on DDL)
# Note: New-SQLiteConnection returns an ALREADY OPEN connection.
# ---------------------------------------------------------------------------
function Invoke-SchemaSQL {
    param([string]$DbPath, [string]$SqlText)

    # New-SQLiteConnection opens the connection automatically
    $conn = New-SQLiteConnection -DataSource $DbPath

    try {
        # Split on semicolons; strip full-line comments from each chunk,
        # then skip empty chunks
        $statements = $SqlText -split ';' | ForEach-Object {
            # Remove lines that are pure comments or blank
            ($_ -split "`n" | Where-Object {
                $line = $_.Trim()
                $line -ne '' -and -not $line.StartsWith('--')
            }) -join "`n"
        } | Where-Object { $_.Trim() -match '\S' }

        foreach ($stmt in $statements) {
            $cmd = $conn.CreateCommand()
            $cmd.CommandText = $stmt.Trim() + ";"
            [void]$cmd.ExecuteNonQuery()
            $cmd.Dispose()
        }
    }
    finally {
        $conn.Close()
        $conn.Dispose()
    }
}

# ---------------------------------------------------------------------------
# SQLite init
# ---------------------------------------------------------------------------
if ($usePSSQLite) {
    # Ensure parent directory exists
    $dbDir = Split-Path $dbPath -Parent
    if (-not (Test-Path $dbDir)) {
        New-Item -ItemType Directory -Path $dbDir -Force | Out-Null
        Write-Host "[INIT] Created DB directory: $dbDir"
    }

    if ($Force -and (Test-Path $dbPath)) {
        Remove-Item $dbPath -Force
        Write-Host "[INIT] Removed existing DB for Force-reset." -ForegroundColor Yellow
    }

    if (-not (Test-Path $schemaPath)) {
        throw "Schema file not found: $schemaPath"
    }

    $sql = Get-Content $schemaPath -Raw

    Write-Host "[INIT] Applying schema to: $dbPath"
    Invoke-SchemaSQL -DbPath $dbPath -SqlText $sql
    Write-Host "[INIT] Schema applied." -ForegroundColor Green

    # Verify tables
    $tables = Invoke-SqliteQuery -DataSource $dbPath -Query "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;"
    Write-Host "[INIT] Tables created:" -ForegroundColor Green
    $tables | ForEach-Object { Write-Host "        $_" }

    # Write backend marker into config (in-memory note only; don't mutate config file)
    Write-Host "[INIT] Backend: SQLite (PSSQLite)" -ForegroundColor Green
}

# ---------------------------------------------------------------------------
# JSON fallback init
# ---------------------------------------------------------------------------
if ($useJsonFallback) {
    $jsonDir = Split-Path $jsonPath -Parent
    if (-not (Test-Path $jsonDir)) {
        New-Item -ItemType Directory -Path $jsonDir -Force | Out-Null
    }

    if ($Force -and (Test-Path $jsonPath)) {
        Remove-Item $jsonPath -Force
        Write-Host "[INIT] Removed existing JSON store for Force-reset."
    }

    if (-not (Test-Path $jsonPath)) {
        $store = [ordered]@{
            schema_version = 1
            created_at     = (Get-Date -Format "o")
            threads        = @{}
            events         = [System.Collections.Generic.List[object]]::new()
            violations     = [System.Collections.Generic.List[object]]::new()
            collector_state = @{}
        }
        $store | ConvertTo-Json -Depth 10 | Set-Content $jsonPath -Encoding UTF8
        Write-Host "[INIT] JSON store created: $jsonPath" -ForegroundColor Green
    } else {
        Write-Host "[INIT] JSON store already exists: $jsonPath"
    }
    Write-Host "[INIT] Backend: JSON file store (fallback)" -ForegroundColor Yellow
}

# ---------------------------------------------------------------------------
# Ensure JSONL log file exists
# ---------------------------------------------------------------------------
$logPath = $cfg.logging.jsonl_path
$logDir  = Split-Path $logPath -Parent
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
if (-not (Test-Path $logPath)) {
    New-Item -ItemType File -Path $logPath -Force | Out-Null
    Write-Host "[INIT] Created JSONL log: $logPath"
}

# ---------------------------------------------------------------------------
# Log the init event
# ---------------------------------------------------------------------------
Write-TF-Log -Config $cfg -Type "db_initialized" -Details @{
    backend      = if ($usePSSQLite) { "sqlite" } else { "json_fallback" }
    db_path      = if ($usePSSQLite) { $dbPath } else { $jsonPath }
    force_reset  = [bool]$Force
} -DryRun $cfg.dry_run

Write-Host ""
Write-Host "[INIT] Done. Taskflow DB is ready." -ForegroundColor Cyan
Write-Host "[INIT] Note: system starts DISABLED (enabled=false) and in dry-run mode."
Write-Host "[INIT] Edit taskflow-config.json to enable when ready."
