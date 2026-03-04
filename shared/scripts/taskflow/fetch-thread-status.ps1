param(
  [Parameter(Mandatory=$true)][string]$BotToken,
  [Parameter(Mandatory=$true)][string]$ChannelId,
  [Parameter(Mandatory=$true)][string]$ThreadTs
)

$ErrorActionPreference = 'Stop'

$hdr = @{ "Authorization" = "Bearer $BotToken"; "Content-Type" = "application/json" }

$bodyReplies = @{ channel = $ChannelId; ts = $ThreadTs; limit = 200; inclusive = $true } | ConvertTo-Json -Depth 5
$replies = Invoke-RestMethod -Method Post -Uri 'https://slack.com/api/conversations.replies' -Headers $hdr -Body $bodyReplies

$bodyReac = @{ channel = $ChannelId; timestamp = $ThreadTs; full = $true } | ConvertTo-Json -Depth 5
$reac = Invoke-RestMethod -Method Post -Uri 'https://slack.com/api/reactions.get' -Headers $hdr -Body $bodyReac

if (-not $replies.ok) {
  [pscustomobject]@{ ok = $false; api = 'conversations.replies'; error = $replies.error } | ConvertTo-Json -Depth 6
  exit 0
}

$last = $replies.messages | Select-Object -Last 1
$reacs = @()
if ($reac.ok -and $reac.message.reactions) {
  $reacs = $reac.message.reactions | ForEach-Object { "$($_.name):$($_.count)" }
}

[pscustomobject]@{
  ok          = $true
  reply_count = ($replies.messages | Measure-Object).Count
  latest_ts   = $last.ts
  last_user   = $last.user
  last_text   = $last.text
  reactions   = $reacs
} | ConvertTo-Json -Depth 6
