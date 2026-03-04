param([int]$Port)
$ErrorActionPreference='Stop'
try {
  $conn = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($null -eq $conn) { Write-Output 'no listener'; exit 0 }
  $procId = $conn.OwningProcess
  Stop-Process -Id $procId -Force -ErrorAction Stop
  Start-Sleep -Seconds 1
  Write-Output ("stopped pid $procId")
} catch {
  Write-Output ("error: " + $_.Exception.Message)
  exit 1
}
