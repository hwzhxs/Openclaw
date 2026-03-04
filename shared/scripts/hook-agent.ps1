param(
  [Parameter(Mandatory=$true)][int]$Port,
  [Parameter(Mandatory=$true)][string]$BearerToken,
  [Parameter(Mandatory=$true)][string]$Message,
  [bool]$Deliver = $true
)
$ErrorActionPreference='Stop'
$uri = "http://127.0.0.1:$Port/hooks/agent"
$body = @{ message = $Message; deliver = $Deliver } | ConvertTo-Json -Compress
Invoke-RestMethod -Method Post -Uri $uri -Headers @{ Authorization = "Bearer $BearerToken" } -ContentType 'application/json' -Body $body
