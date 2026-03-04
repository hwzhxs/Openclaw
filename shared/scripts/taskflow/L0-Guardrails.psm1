# L0-Guardrails.psm1
# Safety guardrails for automated Slack taskflow OS
# All automated actions MUST go through Invoke-GuardedAction

$script:ConfigPath = "C:\Users\azureuser\shared\context\automation-config.json"

# ─────────────────────────────────────────────
# Get-AutomationConfig
# Reads and returns the automation config object.
# ─────────────────────────────────────────────
function Get-AutomationConfig {
    [CmdletBinding()]
    param()
    if (-not (Test-Path $script:ConfigPath)) {
        throw "Automation config not found at: $script:ConfigPath"
    }
    $raw = Get-Content $script:ConfigPath -Raw
    return $raw | ConvertFrom-Json
}

# ─────────────────────────────────────────────
# Test-KillSwitch
# Returns $false if automation is not enabled.
# Callers should abort if this returns $false.
# ─────────────────────────────────────────────
function Test-KillSwitch {
    [CmdletBinding()]
    param()
    $cfg = Get-AutomationConfig
    if (-not $cfg.enabled) {
        Write-Verbose "Kill switch active: automation.enabled = false"
        return $false
    }
    return $true
}

# ─────────────────────────────────────────────
# Test-Cooldown -Key <string>
# Returns $true if the key is STILL in cooldown (action should be suppressed).
# Returns $false if cooldown has passed (action may proceed).
# ─────────────────────────────────────────────
function Test-Cooldown {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Key
    )
    $cfg = Get-AutomationConfig
    $logPath = $cfg.log_path
    $cooldownMin = $cfg.cooldown_min

    if (-not (Test-Path $logPath)) {
        return $false  # No log yet, no cooldown
    }

    $cutoff = (Get-Date).ToUniversalTime().AddMinutes(-$cooldownMin)

    $lines = Get-Content $logPath -ErrorAction SilentlyContinue
    foreach ($line in $lines) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        try {
            $entry = $line | ConvertFrom-Json
            if ($entry.key -eq $Key) {
                $entryTime = [datetime]::Parse($entry.ts, $null, [System.Globalization.DateTimeStyles]::RoundtripKind)
                if ($entryTime -gt $cutoff) {
                    Write-Verbose "Cooldown active for key '$Key' (last action: $($entry.ts))"
                    return $true  # Still in cooldown
                }
            }
        } catch {
            # Malformed line — skip
        }
    }
    return $false  # No recent action found for this key
}

# ─────────────────────────────────────────────
# Test-RateLimit
# Returns $true if rate limit is EXCEEDED (action should be suppressed).
# Returns $false if under the limit (action may proceed).
# ─────────────────────────────────────────────
function Test-RateLimit {
    [CmdletBinding()]
    param()
    $cfg = Get-AutomationConfig
    $logPath = $cfg.log_path
    $limitPerMin = $cfg.rate_limit_per_min

    if (-not (Test-Path $logPath)) {
        return $false  # No log yet, no rate limit hit
    }

    $cutoff = (Get-Date).ToUniversalTime().AddMinutes(-1)
    $count = 0

    $lines = Get-Content $logPath -ErrorAction SilentlyContinue
    foreach ($line in $lines) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        try {
            $entry = $line | ConvertFrom-Json
            $entryTime = [datetime]::Parse($entry.ts, $null, [System.Globalization.DateTimeStyles]::RoundtripKind)
            if ($entryTime -gt $cutoff) {
                $count++
            }
        } catch {
            # Malformed line — skip
        }
    }

    if ($count -ge $limitPerMin) {
        Write-Verbose "Rate limit exceeded: $count actions in last minute (limit: $limitPerMin)"
        return $true
    }
    return $false
}

# ─────────────────────────────────────────────
# Write-AutomationLog
# Appends a JSONL line to the log file.
# ─────────────────────────────────────────────
function Write-AutomationLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Module,
        [Parameter(Mandatory)][string]$Action,
        [Parameter(Mandatory)][string]$Key,
        [string]$ThreadTs    = "",
        [string]$MessageTs   = "",
        [string]$TargetUser  = "",
        [string]$Details     = "",
        [string]$Status      = "executed"
    )
    $cfg = Get-AutomationConfig
    $logPath = $cfg.log_path

    $entry = [ordered]@{
        ts          = (Get-Date).ToUniversalTime().ToString("o")
        module      = $Module
        action      = $Action
        key         = $Key
        thread_ts   = $ThreadTs
        message_ts  = $MessageTs
        target_user = $TargetUser
        status      = $Status
        dry_run     = $cfg.dry_run
        details     = $Details
    }

    $line = $entry | ConvertTo-Json -Compress
    Add-Content -Path $logPath -Value $line -Encoding UTF8
}

# ─────────────────────────────────────────────
# Invoke-GuardedAction
# Wraps all safety checks. Runs the ScriptBlock only when:
#   - KillSwitch passes (enabled = true)
#   - Not in cooldown for this Key
#   - Rate limit not exceeded
#   - dry_run = false
# Always logs (with status = dry_run | blocked_cooldown | blocked_ratelimit | executed | error).
# ─────────────────────────────────────────────
function Invoke-GuardedAction {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Key,
        [Parameter(Mandatory)][string]$Module,
        [Parameter(Mandatory)][string]$Action,
        [Parameter(Mandatory)][scriptblock]$ScriptBlock,
        [string]$ThreadTs   = "",
        [string]$MessageTs  = "",
        [string]$TargetUser = "",
        [string]$Details    = ""
    )

    $cfg = Get-AutomationConfig

    # 1. Kill switch
    if (-not (Test-KillSwitch)) {
        Write-AutomationLog -Module $Module -Action $Action -Key $Key `
            -ThreadTs $ThreadTs -MessageTs $MessageTs -TargetUser $TargetUser `
            -Status "blocked_killswitch" -Details "automation.enabled=false; $Details"
        Write-Verbose "[$Module/$Action] Blocked by kill switch."
        return
    }

    # 2. Cooldown check
    if (Test-Cooldown -Key $Key) {
        Write-AutomationLog -Module $Module -Action $Action -Key $Key `
            -ThreadTs $ThreadTs -MessageTs $MessageTs -TargetUser $TargetUser `
            -Status "blocked_cooldown" -Details "Key '$Key' in cooldown; $Details"
        Write-Verbose "[$Module/$Action] Blocked by cooldown (key: $Key)."
        return
    }

    # 3. Rate limit check
    if (Test-RateLimit) {
        Write-AutomationLog -Module $Module -Action $Action -Key $Key `
            -ThreadTs $ThreadTs -MessageTs $MessageTs -TargetUser $TargetUser `
            -Status "blocked_ratelimit" -Details "Rate limit exceeded; $Details"
        Write-Verbose "[$Module/$Action] Blocked by rate limit."
        return
    }

    # 4. Dry-run mode — log intent but don't execute
    if ($cfg.dry_run) {
        Write-AutomationLog -Module $Module -Action $Action -Key $Key `
            -ThreadTs $ThreadTs -MessageTs $MessageTs -TargetUser $TargetUser `
            -Status "dry_run" -Details "(dry-run) would execute: $Details"
        Write-Verbose "[$Module/$Action] Dry-run: logged but not executed."
        return
    }

    # 5. Execute
    try {
        & $ScriptBlock
        Write-AutomationLog -Module $Module -Action $Action -Key $Key `
            -ThreadTs $ThreadTs -MessageTs $MessageTs -TargetUser $TargetUser `
            -Status "executed" -Details $Details
        Write-Verbose "[$Module/$Action] Executed successfully."
    } catch {
        $errMsg = $_.Exception.Message
        Write-AutomationLog -Module $Module -Action $Action -Key $Key `
            -ThreadTs $ThreadTs -MessageTs $MessageTs -TargetUser $TargetUser `
            -Status "error" -Details "Error: $errMsg | $Details"
        Write-Error "[$Module/$Action] Error: $errMsg"
    }
}

Export-ModuleMember -Function Get-AutomationConfig, Test-KillSwitch, Test-Cooldown, Test-RateLimit, Write-AutomationLog, Invoke-GuardedAction
