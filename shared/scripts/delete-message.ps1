. "$PSScriptRoot\load-secrets.ps1"
param($Channel, $Timestamp)
$token = $env:SLACK_BOT_TOKEN
$body = @{channel=$Channel; ts=$Timestamp} | ConvertTo-Json
$headers = @{Authorization="Bearer $token"; 'Content-Type'='application/json'}
$resp = Invoke-WebRequest -Uri 'https://slack.com/api/chat.delete' -Method POST -Headers $headers -Body $body -UseBasicParsing
Write-Output $resp.Content

