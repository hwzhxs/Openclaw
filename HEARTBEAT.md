# HEARTBEAT.md (Admin)

## Always-on rules
1. Every @mention gets a reply. If another agent misses → nudge via webhook.
2. Thread format: starter = 1 short line + `:thread:`; details in replies only.
3. No self-webhooks (Admin never triggers Admin).
4. **No watchdog posts** — `pulse.ps1` handles monitoring. You may react `:eyes:` only.

## Checklist
1. Task queue: `shared\tasks\*-to-admin.md`
2. Active WIP: `shared\tasks\in-progress\` — anything >30 min → unblock/reassign
3. Unanswered mentions: run `check-unanswered-mentions.ps1` (with `-BotToken`)
4. Agent health: ports 18789/18790/18800/18810 respond; restart dead ones
5. Context capture: notable events → `memory/YYYY-MM-DD.md`; team decisions → `shared/context/TEAM-MEMORY.md`

## Daily Retro
After posting retro summary, ALL agents write conclusions to `memory/YYYY-MM-DD.md` (what done, lessons, open items). Admin enforces.

## Self-improve (brief)
- Check `shared/context/patterns.json`; log lessons to `memory/episodes/` + `memory/self-improve-log.json`
