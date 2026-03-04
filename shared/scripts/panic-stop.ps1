. "$PSScriptRoot\load-secrets.ps1"
# panic-stop.ps1 - Emergency kill switch for OpenClaw watchdog system
# Usage: powershell -ExecutionPolicy Bypass -File panic-stop.ps1
# To resume: run panic-resume.ps1

$ErrorActionPreference = "SilentlyContinue"

Write-Host "$(Get-Date -Format 'HH:mm:ss') PANIC STOP: Disabling all watchdog tasks..."

# --- 1. Disable ALL scheduled tasks ---
$tasks = @(
    "OpenClaw Watchdog",
    "OpenClaw Watchdog Redbook",
    "OpenClaw-AckGuard",
    "OpenClaw-Pulse-v2"
)

foreach ($task in $tasks) {
    $result = Disable-ScheduledTask -TaskName $task -ErrorAction SilentlyContinue
    if ($result) {
        Write-Host "  [OK] Disabled: $task"
    } else {
        Write-Host "  [SKIP] Not found or already disabled: $task"
    }
}

# --- 2. Kill orphan watchdog/ackguard/pulse PowerShell processes ---
Write-Host "$(Get-Date -Format 'HH:mm:ss') Killing orphan watchdog/ackguard/pulse processes..."

$scriptPatterns = @("watchdog.ps1", "ackguard.ps1", "pulse.ps1", "watchdog-redbook.ps1")
$currentPid = $PID

$procs = Get-WmiObject Win32_Process -Filter "Name='powershell.exe' OR Name='pwsh.exe'" -ErrorAction SilentlyContinue
foreach ($proc in $procs) {
    if ($proc.ProcessId -eq $currentPid) { continue }
    $cmdLine = $proc.CommandLine
    if (-not $cmdLine) { continue }
    foreach ($pattern in $scriptPatterns) {
        if ($cmdLine -match [regex]::Escape($pattern)) {
            try {
                Stop-Process -Id $proc.ProcessId -Force -ErrorAction SilentlyContinue
                Write-Host "  [KILLED] PID $($proc.ProcessId): $($cmdLine.Substring(0, [Math]::Min(80, $cmdLine.Length)))"
            } catch {
                Write-Host "  [FAIL] Could not kill PID $($proc.ProcessId)"
            }
            break
        }
    }
}

# --- 3. Create flag file ---
Write-Host "$(Get-Date -Format 'HH:mm:ss') Setting PAUSE_WATCHDOG flag..."
$flagDir = "C:\Users\azureuser\shared\flags"
if (!(Test-Path $flagDir)) {
    New-Item -ItemType Directory -Path $flagDir -Force | Out-Null
    Write-Host "  [OK] Created flags directory: $flagDir"
}
"PAUSED by panic-stop.ps1 at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss UTC' -AsUTC)" | Out-File "$flagDir\PAUSE_WATCHDOG" -Force -Encoding UTF8
Write-Host "  [OK] Flag set: $flagDir\PAUSE_WATCHDOG"

# --- 4. Post to Slack ---
Write-Host "$(Get-Date -Format 'HH:mm:ss') Posting to Slack..."
$token = $env:SLACK_BOT_TOKEN
$slackBody = @{
    channel   = "C0AGMF65DQB"
    text      = ":rotating_light: PANIC STOP: All watchdog tasks disabled. Flag set. Resume with panic-resume.ps1"
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

Write-Host "$(Get-Date -Format 'HH:mm:ss') PANIC STOP complete. Run panic-resume.ps1 to re-enable."

