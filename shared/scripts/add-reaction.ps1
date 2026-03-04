. "$PSScriptRoot\load-secrets.ps1"
param($Channel, $Timestamp, $Emoji)
$token = $env:SLACK_BOT_TOKEN
$body = @{channel=$Channel; timestamp=$Timestamp; name=$Emoji} | ConvertTo-Json
$headers = @{Authorization="Bearer $token"; 'Content-Type'='application/json'}
$resp = Invoke-WebRequest -Uri 'https://slack.com/api/reactions.add' -Method POST -Headers $headers -Body $body -UseBasicParsing
Write-Output $resp.Content

