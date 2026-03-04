param(
  [Parameter(Mandatory=$true)][string]$BotToken,
  [Parameter(Mandatory=$true)][string]$Channel,
  [Parameter(Mandatory=$true)][string]$Timestamp,
  [Parameter(Mandatory=$true)][string]$Name
)

$hdr = @{ "Authorization" = "Bearer $BotToken"; "Content-Type" = "application/json" }
$body = @{ channel = $Channel; timestamp = $Timestamp; name = $Name } | ConvertTo-Json
$resp = Invoke-RestMethod -Method Post -Uri 'https://slack.com/api/reactions.add' -Headers $hdr -Body $body
$resp | ConvertTo-Json -Depth 6
