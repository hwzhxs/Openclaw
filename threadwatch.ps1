param(
  [string]$Token,
  [string]$Channel,
  [string]$ThreadTs,
  [int]$Minutes = 60
)

$ErrorActionPreference='Stop'

function SlackGet([string]$Url){
  Invoke-RestMethod -Method Get -Uri $Url -Headers @{ Authorization = ('Bearer '+$Token) }
}

$start = Get-Date
$prevLastTs = ''
$prevCount = -1

while((Get-Date) - $start -lt [TimeSpan]::FromMinutes($Minutes)){
  try {
    $repliesUrl = 'https://slack.com/api/conversations.replies?channel=' + $Channel + '&ts=' + $ThreadTs + '&limit=200'
    $replies = SlackGet $repliesUrl
    if(-not $replies.ok){ throw ('replies not ok: ' + ($replies|ConvertTo-Json -Compress)) }

    $msgs = $replies.messages
    $count = $msgs.Count
    $lastTs = ($msgs | Sort-Object {[decimal]$_.ts} | Select-Object -Last 1).ts

    $signal = $null
    $bullets = @()

    $root = $msgs | Sort-Object {[decimal]$_.ts} | Select-Object -First 1
    if($root.subtype -eq 'tombstone'){
      $signal='orphan_cleanup'
      $bullets += 'Root message is tombstone (deleted) but thread replies still present.'
      $bullets += ('Reply count now: ' + $count + '; last reply ts: ' + $lastTs)
    }

    if(-not $signal){
      if($prevCount -ge 0 -and ($count -ne $prevCount -or $lastTs -ne $prevLastTs)){
        $signal='new_message'
        $bullets += ('Reply count: ' + $prevCount + ' -> ' + $count)
        $bullets += ('Last ts: ' + $prevLastTs + ' -> ' + $lastTs)
      }
    }

    $lastMsg = ($msgs | Sort-Object {[decimal]$_.ts} | Select-Object -Last 1)
    $text = [string]$lastMsg.text
    if($text){
      if($text -match '\b(PICKUP|WORKING|DONE|HANDOFF|REVIEW|FINAL)\b'){
        $signal='progress_marker'
        $bullets += ('Marker found in last message: ' + $Matches[1])
      }
      if($text -match 'TOOLS\.md' -or $text -match 'token\s*(scrap|scrape|fallback)'){
        $signal='security_blocker_keywords'
        $bullets += 'Security blocker keyword detected in last message text.'
      }
      if($text -match '<@U0AHN84GJGG>' -or $text -match '<@U0AH72QL9L1>' -or $text -match '<@U0AGND9JG4B>' -or $text -match '<@U0AGSEVA4EP>'){
        if(-not $signal){ $signal='new_mention' } else { $bullets += 'Also contains @mention.' }
        $bullets += 'Detected @mention in last message.'
      }
    }

    $histUrl = 'https://slack.com/api/conversations.history?channel=' + $Channel + '&limit=20'
    $hist = SlackGet $histUrl
    if($hist.ok){
      $top = $hist.messages | Where-Object { $_.user -eq 'U0AGSEVA4EP' -and -not $_.thread_ts } | Sort-Object {[decimal]$_.ts} | Select-Object -Last 1
      if($top){
        $t = [string]$top.text
        if($t -match '(?i)\bL\s*project\b|L项目|项目L'){
          $signal='misplaced_reply'
          $bullets += ('Creator posted top-level about L project at ts ' + $top.ts)
        }
      }
    }

    if($signal){
      Write-Output ('[EVENT] Thread: ' + $ThreadTs + ' | Signal: ' + $signal)
      foreach($b in ($bullets | Select-Object -First 3)){ Write-Output (' - ' + $b) }

      $meaningful = $msgs | Where-Object { $_.text -and $_.text.Trim().Length -gt 0 } | Sort-Object {[decimal]$_.ts}
      $last2 = $meaningful | Select-Object -Last 2
      Write-Output ' Last 2 meaningful messages:'
      foreach($m in $last2){
        $u = $m.user; $ts = $m.ts; $tx = ([string]$m.text).Replace("`n",' ')
        if($tx.Length -gt 200){ $tx = $tx.Substring(0,200) + '…' }
        Write-Output ('  • [' + $ts + '] ' + $u + ': ' + $tx)
      }
      Write-Output '---'
    } else {
      $elapsed = (Get-Date) - $start
      if(($elapsed.TotalSeconds % 300) -lt 30){
        Write-Output ('[HEARTBEAT] Thread: ' + $ThreadTs + ' | replies=' + $count + ' | lastTs=' + $lastTs)
      }
    }

    $prevCount = $count
    $prevLastTs = $lastTs
  } catch {
    Write-Output ('[ERROR] ' + $_.Exception.Message)
  }

  Start-Sleep -Seconds 30
}

Write-Output '[DONE] watcher complete'
