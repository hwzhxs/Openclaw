# Monitoring System Inventory (Final State)
# Last updated: 2026-03-03 10:42 UTC

## Active Scripts (shared/scripts/)
| File | Size | Purpose |
|---|---|---|
| pulse.ps1 | 17KB (target <5KB) | Sole monitoring entry point |
| pulse-state.json | ~2KB | Sole state file |
| panic-stop.ps1 | 3KB | Kill switch — creates PAUSE flag |
| panic-resume.ps1 | 2KB | Resume — removes PAUSE flag |
| slack-notify.ps1 | 6KB | Send Slack + fire webhooks |
| slack-send.ps1 | 12KB | Send Slack (no webhook) |
| add-reaction.ps1 | <1KB | Slack emoji react |
| delete-message.ps1 | <1KB | Slack message delete |
| load-secrets.ps1 | <1KB | Credential loader |

## Active Scheduled Tasks
| Task | Script | Interval | Status |
|---|---|---|---|
| OpenClaw-Pulse-v2 | pulse.ps1 | 2min | Ready |
| OpenClaw-Redbook-AllMonitor | redbook-all-monitor.ps1 | periodic | Ready (separate concern) |

## Disabled Scheduled Tasks (do not delete)
- OpenClaw Watchdog, OpenClaw Watchdog Redbook
- OpenClaw-ThreadWatch-agent-team-*, OpenClaw-ThreadWatch-redbook-*
- OpenClaw-AckGuard
- OpenClaw-Taskflow-Collector, OpenClaw-TaskflowCollector-agent-team

## Archived (shared/scripts/archive/)
All watchdog variants, guard scripts, one-time tools. Permanently archived per Xiaosong decision 2026-03-03.

## Documentation
- `shared/context/pulse-v2-spec.md` — sole spec (keep)
- `shared/context/TEAM-MEMORY.md` — consolidated monitoring section (governance rules + anti-patterns)
- MONITORING-MEMORY.md, monitoring-system.md — DELETED (merged into TEAM-MEMORY)

## Governance
See TEAM-MEMORY.md section "2026-03-03: Monitoring System Consolidation" for full rules.
