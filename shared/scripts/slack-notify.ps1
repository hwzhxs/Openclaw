<#
.SYNOPSIS
    Send Slack message with @mentions AND auto-fire webhooks. One call, no forgetting.
.PARAMETER Channel
    Slack channel ID (default: C0AGMF65DQB)
.PARAMETER Message
    Message text (include <@BOT_ID> mentions as needed)
.PARAMETER ReplyTo
    Thread timestamp to reply to (optional, for thread replies)
.PARAMETER WebhookMessage
    Message to send via webhook to mentioned agents (optional)
.PARAMETER BotToken
    Slack bot token to use for sending (default: Admin's token)
.PARAMETER SenderUserId
    Optional Slack user ID of the sender. If provided, that agent's webhook will be skipped to avoid self-wake-up loops.
#>
param(
    [string]$Channel = "C0AGMF65DQB",
    [Parameter(Mandatory)][string]$Message,
    [string]$ReplyTo,
    [string]$WebhookMessage,
    [Parameter(Mandatory)][string]$BotToken,
    [string]$SenderUserId = ""
)

# Fix Chinese/Unicode encoding (PowerShell defaults to US-ASCII which destroys CJK characters)
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Load secrets from centralized store (must come after param block)
. "$PSScriptRoot\load-secrets.ps1"

# Agent registry
$agents = @{
    "U0AH72QL9L1" = @{Name="Thinker";    Port=18790; Token=$env:OPENCLAW_WEBHOOK_THINKER}
    "U0AGND9JG4B" = @{Name="Gatekeeper"; Port=18800; Token=$env:OPENCLAW_WEBHOOK_GATEKEEPER}
    "U0AGSEVA4EP" = @{Name="Creator";    Port=18810; Token=$env:OPENCLAW_WEBHOOK_CREATOR}
    "U0AHN84GJGG" = @{Name="Admin";      Port=18789; Token=$env:OPENCLAW_WEBHOOK_ADMIN}
}

# Step 0.5: Auto-fix plain text @mentions → proper Slack <@USERID> format
# This is the STRUCTURAL fix for the recurring "plain text @mention" bug
$plainTextMentions = @{
    '@Admin'      = '<@U0AHN84GJGG>'
    '@Popo'       = '<@U0AHN84GJGG>'
    '@Thinker'    = '<@U0AH72QL9L1>'
    '@Kanye'      = '<@U0AH72QL9L1>'
    '@Gatekeeper' = '<@U0AGND9JG4B>'
    '@Rocky'      = '<@U0AGND9JG4B>'
    '@Creator'    = '<@U0AGSEVA4EP>'
    '@Tyler'      = '<@U0AGSEVA4EP>'
}
foreach ($plain in $plainTextMentions.Keys) {
    if ($Message -cmatch [regex]::Escape($plain)) {
        Write-Host "  AUTO-FIX: '$plain' -> '$($plainTextMentions[$plain])'" -ForegroundColor Magenta
        $Message = $Message -creplace [regex]::Escape($plain), $plainTextMentions[$plain]
    }
}

# Step 1: Detect which agents are @mentioned (skip sender to avoid self-loop)
$mentionedAgents = @()
foreach ($uid in $agents.Keys) {
    if ($Message -match $uid) {
        if ($SenderUserId -and $uid -eq $SenderUserId) {
            Write-Host "  Skipping self-webhook for $($agents[$uid].Name) (sender)" -ForegroundColor DarkYellow
            continue
        }
        $mentionedAgents += $agents[$uid]
    }
}

# Step 2: Actually send the Slack message via API
Write-Host "=== SENDING SLACK MESSAGE ===" -ForegroundColor Cyan
$slackBody = @{
    channel = $Channel
    text    = $Message
}
if ($ReplyTo) { $slackBody.thread_ts = $ReplyTo }

$slackJson = $slackBody | ConvertTo-Json
$slackBytes = [System.Text.Encoding]::UTF8.GetBytes($slackJson)
try {
    $slackResult = Invoke-WebRequest -Uri "https://slack.com/api/chat.postMessage" `
        -Method POST `
        -Headers @{Authorization="Bearer $BotToken"; "Content-Type"="application/json; charset=utf-8"} `
        -Body $slackBytes `
        -UseBasicParsing -TimeoutSec 10
    $slackResponse = $slackResult.Content | ConvertFrom-Json
    if ($slackResponse.ok) {
        Write-Host "  Slack message sent OK (ts: $($slackResponse.ts))" -ForegroundColor Green
        $sentTs = $slackResponse.ts
    } else {
        Write-Host "  Slack message FAILED: $($slackResponse.error)" -ForegroundColor Red
    }
} catch {
    Write-Host "  Slack send FAILED: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 3: Auto-fire webhooks for all mentioned agents
if ($mentionedAgents.Count -gt 0) {
    Write-Host "=== WEBHOOKS ($($mentionedAgents.Count) agents) ===" -ForegroundColor Yellow
    
    $threadRef = if ($ReplyTo) { $ReplyTo } else { if ($sentTs) { $sentTs } else { "top-level" } }
    
    $agentIndex = 0
    foreach ($a in $mentionedAgents) {
        # 3s delay between agents to prevent cascade crashes (aligned 2026-02-27)
        if ($agentIndex -gt 0) {
            Write-Host "  Throttling 3s before next webhook..." -ForegroundColor DarkYellow
            Start-Sleep -Seconds 3
        }
        
        $whMsg = if ($WebhookMessage) { $WebhookMessage } else {
            "You were @mentioned in Slack on channel $Channel (thread: $threadRef). Check and respond in the thread: message(action=send, channel=slack, target=$Channel, replyTo=$threadRef, message='your response')"
        }
        
        $bodyJson = @{message=$whMsg; deliver=$true} | ConvertTo-Json
        $body = [System.Text.Encoding]::UTF8.GetBytes($bodyJson)
        $sent = $false
        for ($attempt = 1; $attempt -le 2; $attempt++) {
            try {
                Invoke-WebRequest -Uri "http://127.0.0.1:$($a.Port)/hooks/agent" `
                    -Method POST `
                    -Headers @{Authorization="Bearer $($a.Token)";"Content-Type"="application/json; charset=utf-8"} `
                    -Body $body `
                    -UseBasicParsing -TimeoutSec 5 | Out-Null
                Write-Host "  $($a.Name): webhook sent OK" -ForegroundColor Green
                $sent = $true
                break
            } catch {
                Write-Host "  $($a.Name): attempt $attempt FAILED - $($_.Exception.Message)" -ForegroundColor Red
                if ($attempt -eq 1) {
                    Write-Host "  Retrying in 10s..." -ForegroundColor DarkYellow
                    Start-Sleep -Seconds 10
                }
            }
        }
        if (-not $sent) {
            # Log failure
            $logLine = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss UTC') | $($a.Name) | port $($a.Port) | FAILED after 2 attempts"
            Add-Content -Path "C:\Users\azureuser\shared\context\webhook-errors.log" -Value $logLine -ErrorAction SilentlyContinue
            Write-Host "  $($a.Name): logged to webhook-errors.log" -ForegroundColor DarkRed
        }
        $agentIndex++
    }
} else {
    Write-Host "No agents @mentioned, no webhooks to fire." -ForegroundColor Gray
}
