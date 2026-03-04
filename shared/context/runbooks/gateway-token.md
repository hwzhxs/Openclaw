# Gateway Token Mismatch Runbook (2026-03-01)

## Root Cause
Gateway starts without `OPENCLAW_CONFIG_PATH`/`OPENCLAW_STATE_DIR` → boots from default `~/.openclaw` → token mismatch. Port LISTENS but UI shows "unauthorized".

## Diagnosis
1. `netstat -ano | findstr ":<PORT>"` → get PID
2. `Get-CimInstance Win32_Process -Filter "ProcessId=<PID>"` → check CommandLine
3. Missing `OPENCLAW_CONFIG_PATH` = rogue bare gateway

## Fix
```powershell
Stop-Process -Id <PID> -Force
Start-Process -FilePath "<agent>\.openclaw\gateway.cmd" -WindowStyle Hidden
```

## Agent Gateway Launchers
| Agent | gateway.cmd | Port |
|---|---|---|
| Admin | `.openclaw\gateway.cmd` | 18789 |
| Thinker | `.openclaw-agent2\gateway.cmd` | 18790 |
| Gatekeeper | `.openclaw-agent3\gateway.cmd` | 18800 |
| Creator | `.openclaw-creator\gateway.cmd` | 18810 |

## Prevention
- ALL gateway.cmd files MUST set both OPENCLAW_STATE_DIR and OPENCLAW_CONFIG_PATH
- Each scheduled task must point to its own agent's gateway.cmd
