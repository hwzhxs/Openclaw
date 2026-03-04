param(
  [Parameter(Mandatory=$true)][string]$Path,
  [string]$Text,
  [string]$TextFile
)
$ErrorActionPreference='Stop'
if(!(Test-Path $Path)){
  $dir = Split-Path -Parent $Path
  if($dir -and !(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
  New-Item -ItemType File -Path $Path -Force | Out-Null
}
if($TextFile){
  $Text = Get-Content -Raw $TextFile
}
if($null -eq $Text){ throw 'Text is required (provide -Text or -TextFile)'}
Add-Content -Path $Path -Value $Text
