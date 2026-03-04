# TOOLS.md - Local Notes

Environment-specific tool configs. Rules & checklists → see AGENTS.md.

## Slack Emoji React (API)
```powershell
$token = "<REDACTED>"
$body = @{channel="C0AGMF65DQB"; timestamp="<messageId>"; name="<emoji_name>"} | ConvertTo-Json
Invoke-WebRequest -Uri "https://slack.com/api/reactions.add" -Method POST -Headers @{Authorization="Bearer $token";"Content-Type"="application/json"} -Body $body -UseBasicParsing
```
Common: `eyes`, `white_check_mark`, `thumbsup`, `fire`, `brain`, `warning`, `100`

## OpenClaw Config Validate
After editing `openclaw.json`, always run before restart:
```powershell
set OPENCLAW_CONFIG_PATH=C:\Users\azureuser\.openclaw-agent2\openclaw.json
openclaw config validate
```
