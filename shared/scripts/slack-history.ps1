param(
  [Parameter(Mandatory=$true)][string]$BotToken,
  [Parameter(Mandatory=$true)][string]$Channel,
  [int]$Limit = 10
)
$ErrorActionPreference='Stop'
$hdr=@{ Authorization = "Bearer $BotToken" }
$uri = "https://slack.com/api/conversations.history?channel=$Channel&limit=$Limit"
$j = Invoke-RestMethod -Uri $uri -Headers $hdr
if(-not $j.ok){ throw "Slack error: $($j.error)" }
$j.messages | Select-Object ts,user,text,reply_count | ConvertTo-Json -Depth 6
