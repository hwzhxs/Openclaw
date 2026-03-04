# TOOLS.md - Local Notes

## Slack Rules
- Threading is handled by `replyToMode: "all"` in openclaw.json — no manual replyTo needed for replies
- Use `replyTo` only when targeting a SPECIFIC thread (not the triggering message)
- Thread starter = ONE short line + 🧵. Details go in thread replies.
- @mention other agents in thread replies only
- If Xiaosong mentions a specific agent, ONLY that agent replies. Others react emoji only.
- Fallback if replyToMode breaks: see `shared/context/slack-threading-fix.md`

## Slack Emoji React (直接调API)

```powershell
$token = $env:SLACK_BOT_TOKEN
$body = @{channel="C0AGMF65DQB"; timestamp="<messageId>"; name="<emoji_name>"} | ConvertTo-Json
Invoke-WebRequest -Uri "https://slack.com/api/reactions.add" -Method POST -Headers @{Authorization="Bearer $token";"Content-Type"="application/json"} -Body $body -UseBasicParsing
```

常用 emoji: `eyes`, `white_check_mark`, `thumbsup`, `fire`, `brain`, `warning`, `100`

**规则：看到 Slack 里的 thread/消息时，必须给个 emoji react！**

## What Goes Here

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Device nicknames
- Anything environment-specific
