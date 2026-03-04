param(
  [Parameter(Mandatory=$true)][string]$BotToken,
  [Parameter(Mandatory=$true)][string]$Channel,
  [Parameter(Mandatory=$true)][string]$ThreadTs,
  [int]$Limit = 200
)
$ErrorActionPreference='Stop'
$hdr=@{ Authorization = "Bearer $BotToken" }
$uri = "https://slack.com/api/conversations.replies?channel=$Channel&ts=$ThreadTs&limit=$Limit"
$r = Invoke-RestMethod -Uri $uri -Method Get -Headers $hdr
if(-not $r.ok){ throw "Slack error: $($r.error)" }
$withFiles = @()
foreach($m in $r.messages){
  if($m.files -and $m.files.Count -gt 0){
    $withFiles += [pscustomobject]@{ ts=$m.ts; user=$m.user; text=$m.text; files=$m.files }
  }
}
$withFiles | ConvertTo-Json -Depth 9
