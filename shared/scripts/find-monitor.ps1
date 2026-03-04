$ErrorActionPreference='SilentlyContinue'
$procs = Get-CimInstance Win32_Process
foreach($p in $procs){
  if($p.CommandLine -and ($p.CommandLine -like '*thread-monitor*' -or $p.CommandLine -like '*taskflow-collector*')){
    Write-Output ("PID={0} Name={1} Cmd={2}" -f $p.ProcessId, $p.Name, $p.CommandLine)
  }
}
Write-Output "SCAN_DONE"
