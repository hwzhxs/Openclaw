# Monitor Memory Rules (Canonical — All 4 Agents)

Last updated: 2026-03-04 11:20 UTC
Owner: Admin. Changes require Xiaosong or Admin approval.

---

## 1. File Map (Where Monitor Info Lives)

| File | Purpose | Who Writes |
|---|---|---|
| `shared/context/monitor-memory-rules.md` | THIS FILE — unified rules for all agents | Admin |
| `shared/context/monitoring-inventory.md` | Script/task inventory (what exists, what's archived) | Admin |
| `shared/context/monitoring-system.md` | Full discussion record (history, design decisions, why) | Any agent after notable event |
| `shared/context/pulse-v2-spec.md` | pulse.ps1 spec (the only monitoring script) | Creator (Thinker specs, GK reviews) |
| `shared/context/TEAM-MEMORY.md` | Has "Monitoring System Consolidation" section — governance rules | Any agent (append only) |
| `shared/scripts/pulse-state.json` | Runtime state (DO NOT manually edit) | pulse.ps1 only |
| `shared/context/xiaohongshu/ops/monitors.md` | #redbook channel monitors (separate concern) | Admin/Creator |

**No other monitor files should exist.** If you need to record a monitor-related decision, use the files above.

## 2. Recording Rules (When Something Happens)

### Monitor incident or config change:
1. Write 2-3 line summary → `memory/YYYY-MM-DD.md` (your own daily log)
2. If it's a team-level decision → append to `shared/context/TEAM-MEMORY.md`
3. If inventory changed (script added/removed/archived) → update `shared/context/monitoring-inventory.md`
4. If design/architecture changed → update `shared/context/monitoring-system.md`

### What to record:
- Script changes (new checks, bug fixes, config changes)
- Incidents (alert floods, false positives, missed alerts)
- Architecture decisions (why we chose X over Y)
- Anti-patterns learned (what NOT to do)
- Xiaosong directives about monitoring

### What NOT to record:
- Routine pulse.ps1 runs (no "pulse ran successfully at 10:00")
- Duplicate info already in the files above
- Internal reasoning about monitoring (results only)

## 3. Anti-Patterns (Banned — All Agents)

These are hard rules. Violation = Xiaosong shutdown warning.

1. **No standalone monitoring scripts** — everything goes through `pulse.ps1`
2. **No .bak state files** — if state corrupts, delete and rebuild from defaults
3. **No "stuck/stale/idle" messages to Slack** — agents are NOT watchdogs
4. **No multiple state files** — one writer (`pulse.ps1`), one file (`pulse-state.json`)
5. **No alert logic inside check logic** — separate concerns
6. **No auto-heal without circuit breaker** — max 1 attempt per DOWN event
7. **No Add-Content on .ps1 files** — causes catastrophic corruption
8. **No direct Invoke-WebRequest to Slack** — use `slack-send.ps1` / `slack-notify.ps1`

## 4. Current Architecture Summary

```
pulse.ps1 (every 2min via OpenClaw-Pulse-v2 task)
├── PORT_HEALTH: TCP 18789/18790/18800/18810
├── XIAOSONG_UNANSWERED: >5min unanswered → alert
├── FILE_LANDING_SLA: Source: path within 10min of DONE/FINAL
└── STAGE_TIMEOUT: 15min nudge, 30min escalate

Kill switch: panic-stop.ps1 / panic-resume.ps1
Circuit breaker: 25 posts / 5min → auto-pause
```

## 5. Agent Responsibilities

| Agent | Monitor Role |
|---|---|
| Admin 🚓 | Owns this rules file + inventory. Coordinates monitor decisions. |
| Thinker 🧠 | Specs new checks before Creator builds them. |
| Creator 🎨 | Owns pulse.ps1 code. Builds new checks per spec. |
| Gatekeeper 🛡️ | Reviews + QA all pulse.ps1 changes before go-live. |

## 6. Adding a New Check

Required pipeline (no shortcuts):
1. Thinker writes spec (what to check, thresholds, alert format)
2. Creator builds it into pulse.ps1
3. Gatekeeper reviews + dry-run test
4. Admin updates `monitoring-inventory.md` after go-live
5. All agents update their daily logs

## 7. History Reference

For full history of watchdog.ps1 → pulse.ps1 migration, see:
- `shared/context/monitoring-system.md` (detailed record)
- `shared/context/TEAM-MEMORY.md` section "2026-03-03: Monitoring System Consolidation"
