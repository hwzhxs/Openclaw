$dirs = @("C:\Users\azureuser\.openclaw\workspace","C:\Users\azureuser\.openclaw-agent2\workspace","C:\Users\azureuser\.openclaw-agent3\workspace","C:\Users\azureuser\.openclaw-creator\workspace","C:\Users\azureuser\shared")
$files = Get-ChildItem $dirs -Recurse -File -EA SilentlyContinue | Where-Object { $_.Extension -match '\.(md|ps1|json|txt)$' -and $_.FullName -notmatch 'node_modules|\\\.git|openclaw\.json' }
$xoxb = $files | Select-String 'xoxb-' -EA SilentlyContinue | Select-Object Path -Unique
Write-Host "xoxb hits (excl openclaw.json): $($xoxb.Count)"
$xoxb | ForEach-Object { Write-Host $_.Path }
