<#
.SYNOPSIS
  Monitor #redbook channel for '@all' (or Slack broadcast tokens) and auto-wake agents via webhook.

.DESCRIPTION
  Polls conversations.history for the channel and tracks last processed ts in a state json.
  When a new message contains '@all' / <!channel> / <!here>, it:
  1) Determines thread_ts (thread_ts if present else message ts)
  2) Posts a small ack message in-thread (optional)
  3) Fires webhooks to Thinker/Creator/Gatekeeper to respond in-thread

.PARAMETER BotToken
  Slack bot token for Admin.
.PARAMETER Channel
  Slack channel id (default: C0AJ4P0T274).
.PARAMETER StatePath
  State file path.
.PARAMETER PostAck
  If set, posts an ack message in the thread.
#>

param(
  [Parameter(Mandatory)][string]$BotToken,
  [string]$Channel = 'C0AJ4P0T274',
  [string]$StatePath = 'C:\Users\azureuser\.openclaw\workspace\shared\context\redbook-all-monitor-state.json',
  [switch]$PostAck
)

$ErrorActionPreference = 'Stop'

function SlackGet([string]$url){
  Invoke-RestMethod -Method Get -Uri $url -Headers @{ Authorization = ('Bearer ' + $BotToken) }
}
function SlackPost([hashtable]$body){
  $json = $body | ConvertTo-Json -Compress
  Invoke-RestMethod -Method Post -Uri 'https://slack.com/api/chat.postMessage' -Headers @{ Authorization = ('Bearer ' + $BotToken); 'Content-Type'='application/json; charset=utf-8'} -Body $json
}

function Send-Webhook([int]$port, [string]$token, [string]$msg){
  $payload = @{ message = $msg; deliver = $true } | ConvertTo-Json -Compress
  Invoke-WebRequest -UseBasicParsing -TimeoutSec 5 -Uri ("http://127.0.0.1:$port/hooks/agent") -Method POST -Headers @{ Authorization = ("Bearer $token"); 'Content-Type'='application/json' } -Body $payload | Out-Null
}

# Agent webhook registry
$agents = @(
  @{Name='Thinker';    Port=18790; Token='hook__openclaw-agent2_secret'}
  @{Name='Creator';    Port=18810; Token='hook__openclaw-creator_secret'}
  @{Name='Gatekeeper'; Port=18800; Token='hook__openclaw-agent3_secret'}
)

# Load state
$lastTs = '0'
if(Test-Path $StatePath){
  try {
    $state = Get-Content $StatePath -Raw | ConvertFrom-Json
    if($state.lastTs){ $lastTs = [string]$state.lastTs }
  } catch { }
}

# Fetch latest history
$histUrl = 'https://slack.com/api/conversations.history?channel=' + $Channel + '&limit=50'
$hist = SlackGet $histUrl
if(-not $hist.ok){ throw ('history not ok: ' + ($hist | ConvertTo-Json -Compress)) }

# Slack returns newest-first
$msgs = @($hist.messages)

# Determine new messages (ts > lastTs)
$new = $msgs | Where-Object { [decimal]$_.ts -gt [decimal]$lastTs } | Sort-Object {[decimal]$_.ts}

$maxSeen = [decimal]$lastTs

foreach($m in $new){
  $ts = [string]$m.ts
  if([decimal]$ts -gt $maxSeen){ $maxSeen = [decimal]$ts }

  $text = [string]$m.text
  if(-not $text){ continue }

  $isAll = $false
  if($text -match '(?i)\@all'){ $isAll = $true }
  if($text -match '<!channel>' -or $text -match '<!here>'){ $isAll = $true }

  if(-not $isAll){ continue }

  $threadTs = if($m.thread_ts){ [string]$m.thread_ts } else { [string]$m.ts }

  if($PostAck){
    try {
      $ack = SlackPost @{ channel=$Channel; thread_ts=$threadTs; text=':white_check_mark: @all detected — waking Thinker/Creator/Gatekeeper via webhook now.' }
    } catch { }
  }

  $whMsg = "@all detected in #redbook (channel $Channel). Please respond in Slack thread: channel=$Channel thread_ts=$threadTs"

  $i = 0
  foreach($a in $agents){
    if($i -gt 0){ Start-Sleep -Seconds 3 }
    try {
      Send-Webhook $a.Port $a.Token $whMsg
    } catch {
      # best-effort; don’t crash the whole run
    }
    $i++
  }
}

# Save state
$newState = @{ lastTs = [string]$maxSeen; updatedUtc = (Get-Date).ToUniversalTime().ToString('s') + 'Z' } | ConvertTo-Json -Depth 3
$newState | Set-Content -Encoding UTF8 -Path $StatePath
