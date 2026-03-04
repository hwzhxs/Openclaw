param(
  [Parameter(Mandatory=$true)][string]$BotToken,
  [Parameter(Mandatory=$true)][string]$OutDir
)
$ErrorActionPreference='Stop'
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$hdr = @{ Authorization = "Bearer $BotToken" }
$items = @(
  @{ name = 'creator.mov'; url = 'https://files.slack.com/files-pri/T0AGMEQ1G3V-F0AHSB5UXP0/download/creator.mp4' },
  @{ name = 'gatekeeper.mov'; url = 'https://files.slack.com/files-pri/T0AGMEQ1G3V-F0AHUCYPLG2/download/gatekeeper.mp4' }
)
foreach($it in $items){
  $path = Join-Path $OutDir $it.name
  Invoke-WebRequest -Uri $it.url -Headers $hdr -OutFile $path -UseBasicParsing
  Get-Item $path | Select-Object Name,Length
}
