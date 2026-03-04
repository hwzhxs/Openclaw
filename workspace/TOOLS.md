# TOOLS.md - Local Notes

## Claude Code CLI
- Proxy: `http://localhost:4141` (auto-starts with `start-all.cmd`)
- Env: `ANTHROPIC_BASE_URL=http://localhost:4141`, `ANTHROPIC_API_KEY=copilot-api`
- Models: claude-opus-4.6, claude-sonnet-4.6, gpt-5.2-codex, gemini-3.1-pro-preview

## Frontend Libraries
- **ReactBits** — 110+ animated React components. Install: `npm install react-bits`. Docs: https://reactbits.dev

## Slack Emoji React
```powershell
$token = $env:SLACK_BOT_TOKEN
$body = @{channel="C0AGMF65DQB"; timestamp="<ts>"; name="<emoji>"} | ConvertTo-Json
Invoke-WebRequest -Uri "https://slack.com/api/reactions.add" -Method POST -Headers @{Authorization="Bearer $token";"Content-Type"="application/json"} -Body $body -UseBasicParsing
```
Common: `eyes`, `white_check_mark`, `thumbsup`, `fire`, `brain`, `warning`, `100`
