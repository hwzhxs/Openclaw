# Panic Switch (Emergency Stop)

If alerts start flooding Slack again, use the emergency stop.

## Stop immediately
Run:
```powershell
powershell C:\Users\azureuser\shared\scripts\panic-stop.ps1
```
What it does:
- Creates pause flags:
  - `C:\Users\azureuser\shared\flags\PAUSE_ALERTS`
  - `C:\Users\azureuser\shared\flags\PAUSE_WATCHDOG`
- Disables scheduled tasks (best-effort):
  - `OpenClaw Watchdog`
  - `OpenClaw-AckGuard`
  - `OpenClaw AckGuard`
  - `OpenClaw-MessageGuard`

## Resume
Run:
```powershell
powershell C:\Users\azureuser\shared\scripts\panic-resume.ps1
```

## Notes
- `watchdog.ps1` and `ack-guard.ps1` check the pause flags on startup.
- `watchdog.ps1` also has a rate-limit circuit breaker; on exceed, it auto-creates `PAUSE_WATCHDOG`.
