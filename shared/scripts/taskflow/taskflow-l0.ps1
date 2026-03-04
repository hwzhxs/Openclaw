#Requires -Version 5.1
<#
.SYNOPSIS
    Taskflow OS - L0 Safety Layer
    Dot-source this module to get kill switch, rate limiter, dedupe, and JSONL logging.

.DESCRIPTION
    Provides:
      - Kill switch  : Invoke-TF-KillCheck   — throws if disabled
      - Rate limiter : Invoke-TF-RateCheck   — throws if over rate limit
      - Dedupe       : Invoke-TF-DedupeCheck — returns $true if duplicate (skip action)
      - JSONL log    : Write-TF-Log          — append structured log entry
      - Slack call   : Invoke-TF-SlackPost   — guarded Slack API wrapper

.USAGE
    . "C:\Users\azureuser\shared\scripts\taskflow\taskflow-l0.ps1"
    $cfg = Get-TFConfig
    Invoke-TF-KillCheck $cfg
#>

# ---------------------------------------------------------------------------
# Internal state (module-scope, survives dot-source within session)
# ---------------------------------------------------------------------------
if (-not (Get-Variable -Name '_TF_RateStore' -Scope Script -ErrorAction SilentlyContinue)) {
    $Script:_TF_RateStore  = [System.Collections.Generic.Dictionary[string, System.Collections.Generic.List[datetime]]]::new()
    $Script:_TF_DedupeStore = [System.Collections.Generic.Dictionary[string, datetime]]::new()
}

# ---------------------------------------------------------------------------
# Config loader
# ---------------------------------------------------------------------------
function Get-TFConfig {
    [CmdletBinding()]
    param(
        [string]$ConfigPath = "$PSScriptRoot\taskflow-config.json"
    )
    if (-not (Test-Path $ConfigPath)) {
        throw "Taskflow config not found at: $ConfigPath"
    }
    $raw = Get-Content $ConfigPath -Raw | ConvertFrom-Json
    # Resolve Slack token: env var > shared config file (NEVER scrape from other files)
    $tokenEnvVar = $raw.slack.token_env_var
    $token = [System.Environment]::GetEnvironmentVariable($tokenEnvVar)
    if ([string]::IsNullOrEmpty($token)) {
        $tokenFile = "C:\Users\azureuser\shared\config\slack-token.txt"
        if (Test-Path $tokenFile) {
            $token = (Get-Content $tokenFile -Raw).Trim()
        }
    }
    # Attach resolved token as a hidden property
    $raw | Add-Member -MemberType NoteProperty -Name '_resolved_token' -Value $token -Force

    # Safety: if dry_run is not explicitly set in config, default to $true (fail-safe)
    if ($null -eq $raw.dry_run) {
        $raw | Add-Member -MemberType NoteProperty -Name 'dry_run' -Value $true -Force
        Write-Warning "[L0] dry_run not set in config — defaulting to true (safe mode)"
    }

    return $raw
}

# ---------------------------------------------------------------------------
# Kill Switch
# ---------------------------------------------------------------------------
function Invoke-TF-KillCheck {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][PSCustomObject]$Config,
        [string]$Context = "unknown"
    )
    if (-not $Config.enabled) {
        $msg = "Taskflow kill switch is OFF (enabled=false). Context: $Context"
        Write-TF-Log -Config $Config -Type "kill_switch_blocked" -Details @{ context = $Context } -DryRun $Config.dry_run
        throw $msg
    }
}

function Test-TFEnabled {
    [CmdletBinding()]
    param([Parameter(Mandatory)][PSCustomObject]$Config)
    return [bool]$Config.enabled
}

# ---------------------------------------------------------------------------
# Rate Limiter
# ---------------------------------------------------------------------------
function Invoke-TF-RateCheck {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][PSCustomObject]$Config,
        [string]$AgentKey = "default",
        [switch]$PassThru   # If set, return $false instead of throwing on limit
    )

    $maxPosts      = [int]$Config.rate_limit.max_posts_per_minute
    $windowSeconds = [int]$Config.rate_limit.window_seconds
    $now           = [datetime]::UtcNow
    $windowStart   = $now.AddSeconds(-$windowSeconds)

    if (-not $Script:_TF_RateStore.ContainsKey($AgentKey)) {
        $Script:_TF_RateStore[$AgentKey] = [System.Collections.Generic.List[datetime]]::new()
    }

    $timestamps = $Script:_TF_RateStore[$AgentKey]

    # Evict entries outside the window
    $evictBefore = $windowStart
    $toRemove = @($timestamps | Where-Object { $_ -lt $evictBefore })
    foreach ($t in $toRemove) { [void]$timestamps.Remove($t) }

    if ($timestamps.Count -ge $maxPosts) {
        $details = @{
            agent_key    = $AgentKey
            current_count = $timestamps.Count
            max_allowed  = $maxPosts
            window_seconds = $windowSeconds
        }
        Write-TF-Log -Config $Config -Type "rate_limit_blocked" -Details $details -DryRun $Config.dry_run

        if ($PassThru) { return $false }
        throw "Rate limit exceeded for agent '$AgentKey': $($timestamps.Count)/$maxPosts posts in last ${windowSeconds}s"
    }

    $timestamps.Add($now)
    if ($PassThru) { return $true }
}

# ---------------------------------------------------------------------------
# Dedupe
# ---------------------------------------------------------------------------
function Get-TFActionHash {
    [CmdletBinding()]
    param(
        [string]$Message,
        [string]$Channel,
        [string]$Action
    )
    $raw = "$Channel|$Action|$Message"
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($raw)
    $sha   = [System.Security.Cryptography.SHA256]::Create()
    $hash  = $sha.ComputeHash($bytes)
    return [System.BitConverter]::ToString($hash) -replace '-', ''
}

function Invoke-TF-DedupeCheck {
    <#
    .SYNOPSIS
        Returns $true if this action is a duplicate (should be skipped).
        Returns $false if it's new (and registers it).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][PSCustomObject]$Config,
        [string]$Message,
        [string]$Channel,
        [string]$Action,
        [string]$Hash   # Optional: pre-computed hash
    )

    $cooldownSeconds = [int]$Config.dedupe.cooldown_seconds
    $maxEntries      = [int]$Config.dedupe.max_cache_entries
    $now             = [datetime]::UtcNow

    if ([string]::IsNullOrEmpty($Hash)) {
        $Hash = Get-TFActionHash -Message $Message -Channel $Channel -Action $Action
    }

    # Prune expired entries
    if ($Script:_TF_DedupeStore.Count -gt $maxEntries) {
        $cutoff = $now.AddSeconds(-$cooldownSeconds)
        $expired = @($Script:_TF_DedupeStore.Keys | Where-Object {
            $Script:_TF_DedupeStore[$_] -lt $cutoff
        })
        foreach ($k in $expired) { $Script:_TF_DedupeStore.Remove($k) | Out-Null }
    }

    if ($Script:_TF_DedupeStore.ContainsKey($Hash)) {
        $lastSeen    = $Script:_TF_DedupeStore[$Hash]
        $ageSeconds  = ($now - $lastSeen).TotalSeconds
        if ($ageSeconds -lt $cooldownSeconds) {
            $details = @{
                hash            = $Hash
                last_seen_utc   = $lastSeen.ToString("o")
                age_seconds     = [math]::Round($ageSeconds, 1)
                cooldown_seconds = $cooldownSeconds
                channel         = $Channel
                action          = $Action
            }
            Write-TF-Log -Config $Config -Type "dedupe_skip" -Details $details -DryRun $Config.dry_run
            return $true   # duplicate — skip
        }
    }

    # Register this action
    $Script:_TF_DedupeStore[$Hash] = $now
    return $false  # not a duplicate — proceed
}

# ---------------------------------------------------------------------------
# JSONL Logger
# ---------------------------------------------------------------------------
function Write-TF-Log {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][PSCustomObject]$Config,
        [Parameter(Mandatory)][string]$Type,
        [hashtable]$Details = @{},
        [bool]$DryRun = $true,
        [string]$AgentKey = "default",
        [string]$LogPath
    )

    if ([string]::IsNullOrEmpty($LogPath)) {
        $LogPath = $Config.logging.jsonl_path
    }

    # Rotate if oversized
    $maxBytes = [long]($Config.logging.max_file_size_mb) * 1MB
    if ((Test-Path $LogPath) -and ((Get-Item $LogPath).Length -gt $maxBytes)) {
        $archivePath = $LogPath -replace '\.jsonl$', "-$(Get-Date -Format 'yyyyMMdd-HHmmss').jsonl"
        Move-Item $LogPath $archivePath -Force
    }

    $entry = [ordered]@{
        timestamp = (Get-Date -Format "o")
        type      = $Type
        dry_run   = $DryRun
        agent_key = $AgentKey
        details   = $Details
    }

    $json = $entry | ConvertTo-Json -Compress -Depth 10
    Add-Content -Path $LogPath -Value $json -Encoding UTF8
}

# ---------------------------------------------------------------------------
# Slack API Wrapper (guarded)
# ---------------------------------------------------------------------------
function Invoke-TF-SlackAPI {
    <#
    .SYNOPSIS
        Calls a Slack API method with full L0 protection:
        kill-switch → rate-limit → dedupe → (optional) actual call.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][PSCustomObject]$Config,
        [Parameter(Mandatory)][string]$Method,        # e.g. "chat.postMessage"
        [Parameter(Mandatory)][hashtable]$Payload,
        [string]$AgentKey   = "default",
        [string]$DedupeAction = "",                   # Action label for dedupe key
        [switch]$SkipDedupe
    )

    # 1. Kill switch
    Invoke-TF-KillCheck -Config $Config -Context "SlackAPI:$Method"

    # 2. Rate limit
    $allowed = Invoke-TF-RateCheck -Config $Config -AgentKey $AgentKey -PassThru
    if (-not $allowed) { return $null }

    # 3. Dedupe (for postMessage-style actions)
    if (-not $SkipDedupe -and -not [string]::IsNullOrEmpty($DedupeAction)) {
        $channel = if ($Payload.channel) { $Payload.channel } else { "" }
        $text    = if ($Payload.text)    { $Payload.text }    else { ($Payload | ConvertTo-Json -Compress) }
        $isDupe  = Invoke-TF-DedupeCheck -Config $Config -Message $text -Channel $channel -Action $DedupeAction
        if ($isDupe) { return $null }
    }

    # 4. Dry-run guard
    if ($Config.dry_run) {
        $details = @{ method = $Method; payload = $Payload; agent_key = $AgentKey }
        Write-TF-Log -Config $Config -Type "dry_run_slack_call" -Details $details -DryRun $true -AgentKey $AgentKey
        Write-Verbose "[DRY-RUN] Would call Slack API: $Method with payload: $($Payload | ConvertTo-Json -Compress)"
        return [PSCustomObject]@{ ok = $true; dry_run = $true; method = $Method }
    }

    # 5. Actual Slack API call
    $token = $Config._resolved_token
    if ([string]::IsNullOrEmpty($token)) {
        throw "No Slack token available. Set `$env:$($Config.slack.token_env_var) or add 'token' field to config.slack"
    }

    $uri     = "$($Config.slack.api_base)/$Method"
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type"  = "application/json; charset=utf-8"
    }
    $body = $Payload | ConvertTo-Json -Compress -Depth 10

    try {
        $response = Invoke-RestMethod -Uri $uri -Method POST -Headers $headers -Body $body -ErrorAction Stop
        $logType  = if ($response.ok) { "slack_call_ok" } else { "slack_call_error" }
        Write-TF-Log -Config $Config -Type $logType -Details @{
            method   = $Method
            ok       = $response.ok
            error    = if ($response.error) { $response.error } else { $null }
            agent_key = $AgentKey
        } -DryRun $false -AgentKey $AgentKey

        return $response
    }
    catch {
        Write-TF-Log -Config $Config -Type "slack_call_exception" -Details @{
            method    = $Method
            exception = $_.Exception.Message
            agent_key = $AgentKey
        } -DryRun $false -AgentKey $AgentKey
        throw
    }
}

# ---------------------------------------------------------------------------
# Convenience: post a message (the most common guarded action)
# ---------------------------------------------------------------------------
function Send-TFSlackMessage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][PSCustomObject]$Config,
        [Parameter(Mandatory)][string]$Text,
        [string]$Channel  = $Config.slack.default_channel,
        [string]$ThreadTs = "",
        [string]$AgentKey = "default"
    )

    $payload = @{ channel = $Channel; text = $Text }
    if (-not [string]::IsNullOrEmpty($ThreadTs)) {
        $payload.thread_ts = $ThreadTs
    }

    return Invoke-TF-SlackAPI `
        -Config       $Config `
        -Method       "chat.postMessage" `
        -Payload      $payload `
        -AgentKey     $AgentKey `
        -DedupeAction "post_message"
}

# ---------------------------------------------------------------------------
# Convenience: fire a webhook (e.g. agent notification)
# ---------------------------------------------------------------------------
function Send-TFWebhook {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][PSCustomObject]$Config,
        [Parameter(Mandatory)][string]$WebhookUrl,
        [hashtable]$Body      = @{ text = "ping" },
        [string]$AgentKey     = "default",
        [string]$DedupeAction = "webhook_fire"
    )

    # Kill switch & rate limit still apply
    Invoke-TF-KillCheck -Config $Config -Context "Webhook:$WebhookUrl"
    $allowed = Invoke-TF-RateCheck -Config $Config -AgentKey $AgentKey -PassThru
    if (-not $allowed) { return $null }

    # Dedupe
    $bodyText = $Body | ConvertTo-Json -Compress
    $isDupe   = Invoke-TF-DedupeCheck -Config $Config -Message $bodyText -Channel $WebhookUrl -Action $DedupeAction
    if ($isDupe) { return $null }

    if ($Config.dry_run) {
        Write-TF-Log -Config $Config -Type "dry_run_webhook" -Details @{ url = $WebhookUrl; body = $Body } -DryRun $true -AgentKey $AgentKey
        Write-Verbose "[DRY-RUN] Would fire webhook: $WebhookUrl"
        return [PSCustomObject]@{ ok = $true; dry_run = $true }
    }

    $headers  = @{ "Content-Type" = "application/json" }
    $bodyJson = $Body | ConvertTo-Json -Compress -Depth 10

    try {
        $result = Invoke-RestMethod -Uri $WebhookUrl -Method POST -Headers $headers -Body $bodyJson -ErrorAction Stop
        Write-TF-Log -Config $Config -Type "webhook_fired" -Details @{ url = $WebhookUrl } -DryRun $false -AgentKey $AgentKey
        return $result
    }
    catch {
        Write-TF-Log -Config $Config -Type "webhook_exception" -Details @{ url = $WebhookUrl; error = $_.Exception.Message } -DryRun $false -AgentKey $AgentKey
        throw
    }
}

Write-Verbose "Taskflow L0 safety layer loaded."
