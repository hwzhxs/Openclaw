param(
  [Parameter(Mandatory=$true)][string]$BotToken,
  [Parameter(Mandatory=$true)][string]$ChannelId,
  [Parameter(Mandatory=$true)][string]$ThreadTs,
  [int]$PollSeconds = 30,
  [int]$HeartbeatSeconds = 300,
  [int]$MaxHours = 24
)

$ErrorActionPreference = 'Stop'

function Invoke-SlackApi {
  param([string]$Method,[hashtable]$Body)
  $uri = "https://slack.com/api/$Method"
  $json = ($Body | ConvertTo-Json -Depth 10)
  $resp = Invoke-RestMethod -Method Post -Uri $uri -Headers @{ Authorization = "Bearer $BotToken"; 'Content-Type'='application/json' } -Body $json
  if (-not $resp.ok) {
    throw "Slack API $Method failed: $($resp.error)"
  }
  return $resp
}

function Get-Replies {
  $resp = Invoke-SlackApi -Method 'conversations.replies' -Body @{ channel=$ChannelId; ts=$ThreadTs; limit=200; inclusive=$true }
  return $resp.messages
}

function Get-Reactions {
  $resp = Invoke-SlackApi -Method 'reactions.get' -Body @{ channel=$ChannelId; timestamp=$ThreadTs; full=$true }
  return $resp.message.reactions
}

$start = Get-Date
$nextHeartbeat = $start
$lastSeenTs = $ThreadTs

# Completion criteria (user chose 3):
# (a) Gatekeeper posts FINAL in thread
# (b) Admin posts conclusion + adds ✅ reaction on thread starter
# (c) Dry-run report posted in thread
$gatekeeperId = 'U0AGND9JG4B'
$adminId = 'U0AHN84GJGG'

while ($true) {
  $now = Get-Date
  if ($now -gt $start.AddHours($MaxHours)) {
    Write-Output ("[{0:o}] STOP: max runtime reached ({1}h)" -f $now, $MaxHours)
    break
  }

  $msgs = @()
  try {
    $msgs = Get-Replies
  } catch {
    Write-Output ("[{0:o}] ERROR: conversations.replies: {1}" -f $now, $_.Exception.Message)
    Start-Sleep -Seconds ([Math]::Min($PollSeconds, 60))
    continue
  }

  $newMsgs = $msgs | Where-Object { [double]$_.ts -gt [double]$lastSeenTs }
  if ($newMsgs.Count -gt 0) {
    $lastSeenTs = ($msgs | Select-Object -Last 1).ts
    Write-Output ("[{0:o}] new_message: +{1} latest={2}" -f $now, $newMsgs.Count, $lastSeenTs)
  }

  $textAll = ($msgs | ForEach-Object { ($_.text ?? '') }) -join "\n"

  $hasFinalFromGatekeeper = $false
  foreach ($m in $msgs) {
    if ($m.user -eq $gatekeeperId -and ($m.text -match 'FINAL' -or $m.text -match ':checkered_flag:' -or $m.text -match 'checkered_flag')) {
      $hasFinalFromGatekeeper = $true; break
    }
  }

  $hasAdminConclusion = $false
  foreach ($m in $msgs) {
    if ($m.user -eq $adminId -and ($m.text -match 'CONCLUSION' -or $m.text -match '结论' -or $m.text -match '收口')) {
      $hasAdminConclusion = $true; break
    }
  }

  $hasDryRunReport = $false
  if ($textAll -match 'dry[- ]?run' -or $textAll -match 'DRY-RUN' -or $textAll -match 'WOULD_ACTION' -or $textAll -match 'violations' ) {
    # best-effort heuristic; assumes a real report mentions dry-run or WOULD_ACTION
    $hasDryRunReport = $true
  }

  $hasCheckmarkOnStarter = $false
  try {
    $reactions = Get-Reactions
    if ($null -ne $reactions) {
      foreach ($r in $reactions) {
        if ($r.name -in @('white_check_mark','heavy_check_mark','check_mark')) {
          # if present, treat as closure marker
          $hasCheckmarkOnStarter = $true
        }
      }
    }
  } catch {
    Write-Output ("[{0:o}] WARN: reactions.get failed: {1}" -f $now, $_.Exception.Message)
  }

  if ($hasFinalFromGatekeeper -and $hasAdminConclusion -and $hasCheckmarkOnStarter -and $hasDryRunReport) {
    Write-Output ("[{0:o}] COMPLETE: criteria met (FINAL+AdminConclusion+✅+DryRunReport)" -f $now)
    break
  }

  if ($now -ge $nextHeartbeat) {
    Write-Output ("[{0:o}] heartbeat: final={1} admin_conclusion={2} checkmark={3} dryrun_report={4} replies={5} last={6}" -f $now, $hasFinalFromGatekeeper, $hasAdminConclusion, $hasCheckmarkOnStarter, $hasDryRunReport, $msgs.Count, $lastSeenTs)
    $nextHeartbeat = $now.AddSeconds($HeartbeatSeconds)
  }

  Start-Sleep -Seconds $PollSeconds
}
