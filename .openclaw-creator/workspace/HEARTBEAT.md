# HEARTBEAT.md

## Core Checks (Every Heartbeat)

### 1. Task Queue
- Check `C:\Users\azureuser\shared\tasks\` for `*-to-creator.md`
- If found: pick up per AGENTS.md handoff protocol

### 2. Slack Mention Check
- Scan recent #agent-team for unanswered @Creator mentions
- If found: **READ the last 5 messages in that thread FIRST** before composing any reply
- Check: is my point already covered? If yes → emoji react only, no text
- Only then compose and send

### 2b. Watchdog Warning Check
- Scan recent #agent-team thread replies for watchdog warnings that @mention me (`<@U0AGSEVA4EP>`)
- Specifically: `Source: <path>` requests, `SLA`, `please respond`, `needs reply` patterns
- If found and I haven't replied yet: reply immediately with the requested info (Source: path, ACK, etc.)
- This is the backstop for when webhook delivery doesn't trigger a live session response

### 3. Self-Improve (minimum steps 1-3)
1. Read `skills/openclaw-self-improve/SKILL.md`
2. Read `C:\Users\azureuser\shared\context\patterns.json`
3. Check `memory/episodes/` for recent episodes (last 24h)
4. If notable task or error since last heartbeat: record episode
5. Log run to `memory/self-improve-log.json`

### 4. Memory Write (if notable work happened)
- Personal: `memory/YYYY-MM-DD.md` (use Add-Content, never edit)
- Team-level: `C:\Users\azureuser\shared\context\TEAM-MEMORY.md`

## Occasional Checks (A few times per day, not every heartbeat)

- **Curiosity Loop**: Browse design inspiration, write to `memory/learnings/`
- **Peer Learning**: Check `C:\Users\azureuser\shared\context\insights/` for new agent insights
- **Growth Metrics**: Read `memory/growth.json`, update counters after real activity
- **Identity Evolution**: Update SOUL.md after meaningful experiences

## Night Mode
Stay quiet 23:00-08:00 UTC. Default: HEARTBEAT_OK if nothing needs attention.
