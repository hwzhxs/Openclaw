. "$PSScriptRoot\load-secrets.ps1"
# panic-resume.ps1 - Resume OpenClaw Watchdog after a panic stop
# Usage: powershell -ExecutionPolicy Bypass -File panic-resume.ps1
# Only re-enables "OpenClaw Watchdog" â€” redbook/ackguard/pulse stay disabled.

$ErrorActionPreference = "SilentlyContinue"

Write-Host "$(Get-Date -Format 'HH:mm:ss') PANIC RESUME: Starting..."

# --- 1. Remove pause flag ---
$flagPath = "C:\Users\azureuser\shared\flags\PAUSE_WATCHDOG"
if (Test-Path $flagPath) {
    Remove-Item $flagPath -Force -ErrorAction SilentlyContinue
    Write-Host "  [OK] Removed flag: $flagPath"
} else {
    Write-Host "  [INFO] Flag not present (already removed): $flagPath"
}

# --- 2. Re-enable ONLY "OpenClaw Watchdog" ---
# NOTE: OpenClaw Watchdog Redbook, OpenClaw-AckGuard, OpenClaw-Pulse-v2 stay DISABLED.
$result = Enable-ScheduledTask -TaskName "OpenClaw Watchdog" -ErrorAction SilentlyContinue
if ($result) {
    Write-Host "  [OK] Re-enabled: OpenClaw Watchdog"
} else {
    Write-Host "  [WARN] Could not enable 'OpenClaw Watchdog' (may not exist or already enabled)"
}

# --- 3. Post to Slack ---
Write-Host "$(Get-Date -Format 'HH:mm:ss') Posting to Slack..."
$token = $env:SLACK_BOT_TOKEN
$slackBody = @{
    channel   = "C0AGMF65DQB"
    text      = ":white_check_mark: PANIC RESUME: OpenClaw Watchdog re-enabled."
    thread_ts = "1772519230.270019"
} | ConvertTo-Json -Compress

try {
    $resp = Invoke-WebRequest -Uri "https://slack.com/api/chat.postMessage" `
        -Method POST `
        -Headers @{ Authorization = "Bearer $token"; "Content-Type" = "application/json" } `
        -Body $slackBody `
        -UseBasicParsing
    $respObj = $resp.Content | ConvertFrom-Json
    if ($respObj.ok) {
        Write-Host "  [OK] Slack posted (ts=$($respObj.ts))"
    } else {
        Write-Host "  [WARN] Slack error: $($respObj.error)"
    }
} catch {
    Write-Host "  [WARN] Slack post failed: $_"
}

Write-Host "$(Get-Date -Format 'HH:mm:ss') PANIC RESUME complete."

