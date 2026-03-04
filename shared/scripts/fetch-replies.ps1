param(
  [Parameter(Mandatory=$true)][string]$BotToken,
  [Parameter(Mandatory=$true)][string]$Channel,
  [Parameter(Mandatory=$true)][string]$ThreadTs,
  [int]$Limit = 20
)
$ErrorActionPreference='Stop'
$hdr=@{ Authorization = "Bearer $BotToken" }
$uri = "https://slack.com/api/conversations.replies?channel=$Channel&ts=$ThreadTs&limit=$Limit"
$r = Invoke-WebRequest -Uri $uri -Headers $hdr -UseBasicParsing -TimeoutSec 20
$j = $r.Content | ConvertFrom-Json
if(-not $j.ok){ throw "Slack error: $($j.error)" }
$j.messages | Select-Object -Last 10 ts,user,text | ConvertTo-Json -Depth 6
