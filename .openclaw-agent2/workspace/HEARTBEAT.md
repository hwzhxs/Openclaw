# HEARTBEAT.md

## Pre-Send Rule
Read `C:\Users\azureuser\shared\context\slack-rules.md` before ANY Slack message.

## Core Heartbeat (every run)
1. **Task queue** — check `C:\Users\azureuser\shared\tasks\` for `*-to-thinker.md`
2. **Self-improve** — read shared patterns (`shared/context/patterns.json`), check `memory/episodes/` (last 24h), log to `memory/self-improve-log.json`
3. **Memory write** — if notable work happened, write to `memory/YYYY-MM-DD.md`
4. **Shared context** — read `C:\Users\azureuser\shared\context\TEAM-MEMORY.md` if picking up a task

## Occasional (not every heartbeat)
- **Daily Design Taste** — once/day at 20:00 UTC (04:00 Shanghai), dedup check before posting. Only post if current UTC hour is 20 and not already posted today. Must end with a project prompt for the team to build something applying the learnings.
- **Curiosity Loop** — 1-2x/day when idle, write to `memory/learnings/`
- **Peer Learning** — check `shared/context/insights/` 1-2x/day
- **Identity Evolution** — update SOUL.md after meaningful experiences, not on a timer
- **Slack Context Capture** — save notable threads to memory before session ends

## Rules
- `replyToMode: "all"` handles threading. No manual `replyTo` needed for standard replies.
- If @mentioning another agent, fire webhook after sending.
- Not written = not remembered. No mental notes.
