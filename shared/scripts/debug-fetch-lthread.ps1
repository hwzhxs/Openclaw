param(
  [Parameter(Mandatory=$true)][string]$BotToken,
  [Parameter(Mandatory=$true)][string]$Channel,
  [Parameter(Mandatory=$true)][string]$ThreadTs,
  [int]$Tail = 10
)

$ErrorActionPreference='Stop'
$hdr=@{ Authorization = "Bearer $BotToken"; 'Content-Type'='application/json' }
$body=@{ channel=$Channel; ts=$ThreadTs; limit=200; inclusive=$true } | ConvertTo-Json -Depth 5
$r=Invoke-RestMethod -Method Post -Uri 'https://slack.com/api/conversations.replies' -Headers $hdr -Body $body
if(-not $r.ok){ throw "Slack error: $($r.error)" }
$r.messages | Select-Object -Last $Tail ts,user,text | ConvertTo-Json -Depth 6
