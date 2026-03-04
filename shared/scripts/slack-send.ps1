<#
.SYNOPSIS
    Enforced Slack sender. ALL agents MUST use this instead of calling message(action=send) directly.
    Validates rules before sending. Hard rejects on violations.

.PARAMETER Starter
    The thread starter text. MUST be 1 line only. No @mentions allowed here.

.PARAMETER Details
    Optional. Full details/tables/content. Will be posted as a thread reply automatically.

.PARAMETER ReplyTo
    Thread timestamp to reply to. If provided, Starter is treated as a thread reply (no 1-line restriction).

.PARAMETER Mentions
    Optional array of agent user IDs to @mention (e.g. "U0AHN84GJGG","U0AGSEVA4EP").
    Mentions go in the Details reply (never in the Starter). Webhooks are auto-fired.

.PARAMETER Channel
    Slack channel ID. Default: C0AGMF65DQB (#agent-team)

.PARAMETER BotToken
    Slack bot token. Default: Admin's token.

.EXAMPLE
    # New thread - short starter, details in thread
    .\slack-send.ps1 -Starter "Agent names lookup ðŸ§µ" -Details "Here are the IDs: ..."

.EXAMPLE
    # Reply in existing thread
    .\slack-send.ps1 -ReplyTo "1772178366.826499" -Starter "Done, see below." -Details "Full output..."

.EXAMPLE
    # With @mentions (auto-fires webhooks)
    .\slack-send.ps1 -ReplyTo "1772178366.826499" -Starter "Handoff ready ðŸ§µ" -Details "Task complete." -Mentions @("U0AHN84GJGG")
#>
param(
    [Parameter(Mandatory)][string]$Starter,
    [string]$Details,
    [string]$ReplyTo,
    [string[]]$Mentions = @(),
    [string]$Channel = "C0AGMF65DQB",
    [Parameter(Mandatory)][string]$BotToken
)

# Force UTF-8 encoding for Chinese characters (must be after param block)
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8




# Load secrets from centralized store (must come after param block)
. "$PSScriptRoot\load-secrets.ps1"

# Agent registry for webhook firing
$agents = @{
    "U0AH72QL9L1" = @{Name="Thinker";    Port=18790; Token=$env:OPENCLAW_WEBHOOK_THINKER;    Task="OpenClaw Thinker"}
    "U0AGND9JG4B" = @{Name="Gatekeeper"; Port=18800; Token=$env:OPENCLAW_WEBHOOK_GATEKEEPER; Task="OpenClaw Gatekeeper"}
    "U0AGSEVA4EP" = @{Name="Creator";    Port=18810; Token=$env:OPENCLAW_WEBHOOK_CREATOR;    Task="OpenClaw Creator"}
    "U0AHN84GJGG" = @{Name="Admin";      Port=18789; Token=$env:OPENCLAW_WEBHOOK_ADMIN;      Task="OpenClaw Gateway"}
}

# Auto-fix state (prevents restart thrash)
$restartStatePath = "C:\Users\azureuser\shared\context\agent-restart-state.json"

function Read-RestartState {
    if (-not (Test-Path $restartStatePath)) { return @{ agents = @{} } }
    try {
        $raw = Get-Content $restartStatePath -Raw
        if (-not $raw.Trim()) { return @{ agents = @{} } }
        return ($raw | ConvertFrom-Json -AsHashtable)
    } catch {
        return @{ agents = @{}; _warning = "restart_state_read_failed" }
    }
}

function Write-RestartState($state) {
    $dir = Split-Path -Parent $restartStatePath
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
    ($state | ConvertTo-Json -Depth 6) | Set-Content -Encoding UTF8 -Path $restartStatePath
}

function Test-LocalPort([int]$Port) {
    try {
        $c = Test-NetConnection -ComputerName 127.0.0.1 -Port $Port -WarningAction SilentlyContinue
        return [bool]$c.TcpTestSucceeded
    } catch {
        return $false
    }
}

function Restart-AgentOnce([hashtable]$Agent) {
    # Safe boundary: only attempt restart via known Scheduled Task name.
    if (-not $Agent.Task) { return $false }

    $state = Read-RestartState
    if (-not $state.agents) { $state.agents = @{} }
    if (-not $state.agents.ContainsKey($Agent.Name)) { $state.agents[$Agent.Name] = @{ lastRestartAt = 0 } }

    $now = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
    $cooldownSec = 300
    $last = [int]$state.agents[$Agent.Name].lastRestartAt
    if ($now - $last -lt $cooldownSec) {
        return $false
    }

    try {
        # End any stuck run, then start fresh
        schtasks /End /TN "$($Agent.Task)" | Out-Null
    } catch { }

    try {
        schtasks /Run /TN "$($Agent.Task)" | Out-Null
        $state.agents[$Agent.Name].lastRestartAt = $now
        Write-RestartState $state
        return $true
    } catch {
        return $false
    }
}

# ============================================================
# VALIDATION (hard reject - no sends happen before this passes)
# ============================================================

$errors = @()

# Rule 1: If this is a NEW thread starter (no ReplyTo), Starter must be 1 line only
if (-not $ReplyTo) {
    $lines = ($Starter -split "`n" | Where-Object { $_.Trim() -ne "" })
    if ($lines.Count -gt 1) {
        $errors += "VIOLATION: Thread starter must be 1 line only. Got $($lines.Count) lines. Put details in -Details parameter."
    }
    if ($Starter.Length -gt 120) {
        $errors += "VIOLATION: Thread starter too long ($($Starter.Length) chars). Max 120 chars. Put content in -Details."
    }
}

# Rule 2: No @mentions in Starter (format: <@UXXXXXXXX>)
if ($Starter -match "<@U[A-Z0-9]+>") {
    $errors += "VIOLATION: @mentions not allowed in Starter. Put them in -Details or use -Mentions parameter."
}

# Rule 3: No plain-text @mentions anywhere (Starter or Details)
# Plain text @Creator, @Admin etc don't trigger notifications - must use <@USERID>
$agentNames = @("Admin", "Thinker", "Gatekeeper", "Creator", "Popo", "Kanye", "Rocky", "Tyler")
foreach ($name in $agentNames) {
    if ($Starter -match "@$name\b") {
        $errors += "VIOLATION: Plain text '@$name' in Starter. Use -Mentions parameter with the user ID instead. Plain text @mentions don't trigger notifications."
    }
    if ($Details -match "@$name\b") {
        $errors += "VIOLATION: Plain text '@$name' in Details. Use -Mentions parameter with the user ID instead. Plain text @mentions don't trigger notifications."
    }
}

if ($errors.Count -gt 0) {
    Write-Host "=== SLACK SEND REJECTED ===" -ForegroundColor Red
    foreach ($e in $errors) {
        Write-Host "  $e" -ForegroundColor Red
    }
    Write-Host ""
    Write-Host "Fix your message and try again." -ForegroundColor Yellow
    exit 1
}

# ============================================================
# BUILD MESSAGES
# ============================================================

# If Mentions specified, append them to Details (or create Details)
$detailsText = $Details
if ($Mentions.Count -gt 0) {
    $mentionStr = ($Mentions | ForEach-Object { "<@$_>" }) -join " "
    if ($detailsText) {
        $detailsText = "$detailsText`n`n$mentionStr"
    } else {
        $detailsText = $mentionStr
    }
}

# ============================================================
# SEND
# ============================================================

function Send-SlackMessage {
    param([string]$Text, [string]$ThreadTs)
    $body = @{ channel = $Channel; text = $Text }
    if ($ThreadTs) { $body.thread_ts = $ThreadTs }
    $json = $body | ConvertTo-Json -Compress
    # Encode as UTF-8 bytes to preserve Chinese characters end-to-end
    $utf8Bytes = [System.Text.Encoding]::UTF8.GetBytes($json)
    $resp = Invoke-WebRequest -Uri "https://slack.com/api/chat.postMessage" `
        -Method POST `
        -Headers @{Authorization="Bearer $BotToken"; "Content-Type"="application/json; charset=utf-8"} `
        -Body $utf8Bytes -UseBasicParsing -TimeoutSec 10
    return ($resp.Content | ConvertFrom-Json)
}

Write-Host "=== SLACK SEND ===" -ForegroundColor Cyan

# Step 1: Send the starter
$starterResult = Send-SlackMessage -Text $Starter -ThreadTs $ReplyTo
if (-not $starterResult.ok) {
    Write-Host "FAILED to send starter: $($starterResult.error)" -ForegroundColor Red
    exit 1
}
$starterTs = $starterResult.ts
$sentChannel = $starterResult.channel
# POST-SEND SELF-CHECK: verify message landed in the right channel
if ($sentChannel -ne $Channel) {
    Write-Host "!!! WRONG CHANNEL! Expected $Channel, got $sentChannel. Deleting message..." -ForegroundColor Red
    $delBody = @{channel=$sentChannel; ts=$starterTs} | ConvertTo-Json
    Invoke-WebRequest -Uri "https://slack.com/api/chat.delete" -Method POST `
        -Headers @{Authorization="Bearer $BotToken";"Content-Type"="application/json"} `
        -Body $delBody -UseBasicParsing -TimeoutSec 5 | Out-Null
    Write-Host "  Auto-deleted misrouted message." -ForegroundColor Yellow
    exit 1
}
Write-Host "  Starter sent (ts: $starterTs, channel: $sentChannel - VERIFIED)" -ForegroundColor Green

# Step 2: Send details as thread reply (if provided)
$threadTs = if ($ReplyTo) { $ReplyTo } else { $starterTs }

if ($detailsText) {
    $detailsResult = Send-SlackMessage -Text $detailsText -ThreadTs $threadTs
    if (-not $detailsResult.ok) {
        Write-Host "FAILED to send details: $($detailsResult.error)" -ForegroundColor Red
        # Don't exit - starter already sent
    } else {
        Write-Host "  Details sent as thread reply" -ForegroundColor Green
    }
}

# Step 3: Fire webhooks for @mentioned agents
if ($Mentions.Count -gt 0) {
    Write-Host "=== WEBHOOKS ($($Mentions.Count) agents) ===" -ForegroundColor Yellow
    $agentIndex = 0
    foreach ($uid in $Mentions) {
        if ($agentIndex -gt 0) {
            Write-Host "  Throttling 3s..." -ForegroundColor DarkYellow
            Start-Sleep -Seconds 3
        }
        $a = $agents[$uid]
        if (-not $a) {
            Write-Host "  Unknown agent UID: $uid" -ForegroundColor Red
            $agentIndex++
            continue
        }
        $whMsg = "You were @mentioned in Slack on channel $Channel (thread: $threadTs). Check and respond in the thread."
        $whBody = @{message=$whMsg; deliver=$true} | ConvertTo-Json
        try {
            Invoke-WebRequest -Uri "http://127.0.0.1:$($a.Port)/hooks/agent" `
                -Method POST `
                -Headers @{Authorization="Bearer $($a.Token)";"Content-Type"="application/json"} `
                -Body $whBody -UseBasicParsing -TimeoutSec 5 | Out-Null
            Write-Host "  $($a.Name): webhook OK" -ForegroundColor Green
        } catch {
            Write-Host "  $($a.Name): webhook FAILED - $($_.Exception.Message)" -ForegroundColor Red

            # Auto-fix (safe): if agent endpoint appears DOWN, restart once + retry webhook once.
            $portUp = Test-LocalPort -Port ([int]$a.Port)
            if (-not $portUp) {
                $didRestart = Restart-AgentOnce -Agent $a
                if ($didRestart) {
                    Write-Host "  $($a.Name): attempted restart via Scheduled Task '$($a.Task)'; waiting 5s..." -ForegroundColor DarkYellow
                    Start-Sleep -Seconds 5
                }
            }

            # Retry once if port is up now
            if (Test-LocalPort -Port ([int]$a.Port)) {
                try {
                    Invoke-WebRequest -Uri "http://127.0.0.1:$($a.Port)/hooks/agent" `
                        -Method POST `
                        -Headers @{Authorization="Bearer $($a.Token)";"Content-Type"="application/json"} `
                        -Body $whBody -UseBasicParsing -TimeoutSec 5 | Out-Null
                    Write-Host "  $($a.Name): webhook RETRY OK" -ForegroundColor Green
                } catch {
                    Write-Host "  $($a.Name): webhook RETRY FAILED - $($_.Exception.Message)" -ForegroundColor Red
                }
            } else {
                Write-Host "  $($a.Name): still DOWN after restart attempt (or cooldown)." -ForegroundColor DarkYellow
            }
        }
        $agentIndex++
    }
}

Write-Host "=== DONE ===" -ForegroundColor Cyan
Write-Host "Thread TS: $threadTs"

# ============================================================
# POST-SEND: Run violation scanner (catches other agents' violations)
# ============================================================
Write-Host "=== THREADING MONITOR ===" -ForegroundColor DarkGray
try {
    $mon = Join-Path $PSScriptRoot "slack-thread-monitor.ps1"
    if (Test-Path $mon) {
        & $mon -Channel $Channel -LookbackCount 10 -MaxAgeSeconds 90 -BotToken $BotToken
    } else {
        Write-Host "Monitor skipped (missing slack-thread-monitor.ps1)" -ForegroundColor DarkGray
    }
} catch {
    Write-Host "Monitor failed (non-critical): $_" -ForegroundColor DarkGray
}


