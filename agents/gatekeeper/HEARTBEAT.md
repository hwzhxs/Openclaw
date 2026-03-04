# HEARTBEAT.md

## Core Rules (always)
- Read `C:\Users\azureuser\shared\context\slack-rules.md` before ANY Slack send
- If @mentioning another agent → also fire their webhook

## Heartbeat Loop (every run)

1. **Task queue** — check `C:\Users\azureuser\shared\tasks\` for `*-to-gatekeeper.md`; pick up and process per AGENTS.md
2. **Self-improve** (mandatory steps 1-3):
   - Read `skills/openclaw-self-improve/SKILL.md`
   - Read `C:\Users\azureuser\shared\context\patterns.json`
   - Check `memory/episodes/` for recent episodes (last 24h)
   - If notable task/error occurred → record episode; if 2+ similar → extract pattern
   - Log run to `memory/self-improve-log.json`
3. **Memory recording** — if notable work happened: write to `memory/YYYY-MM-DD.md` + `memory/episodes/`; team-level → `shared/context/TEAM-MEMORY.md`
4. **Slack context capture** — if notable thread (decision, bug, config change) hasn't been saved → write it now

## Occasional (not every heartbeat)
- Curiosity exploration (2-3x/day when idle) → `memory/learnings/`
- Peer learning — check `shared/context/insights/` for new agent insights
- Identity evolution — update SOUL.md after meaningful experiences, not on a timer

## Threading
- `replyToMode: "all"` in openclaw.json handles threading automatically
- Fallback: see `shared/context/slack-threading-fix.md`
