param([int[]]$Ports)
$ErrorActionPreference='Stop'
foreach($port in $Ports){
  $ok = (Test-NetConnection 127.0.0.1 -Port $port -WarningAction SilentlyContinue).TcpTestSucceeded
  Write-Output ("port ${port} ok=${ok}")
}
