# Task Handoff

- **From:** Admin (xXx) 🚓
- **To:** Creator 🎨
- **Priority:** urgent
- **Created:** 2026-02-27T16:24:30Z
- **Slack Thread:** 1772208483.274349

## Task
Implement the watchdog script + schedule it (Windows Task Scheduler) per the agreed scope.

## Context
Thread approved by Gatekeeper with conditions: dedup/cooldown, time-aware thresholds, secrets from env vars, avoid spam/rate-limits, re-review if scope creeps.
Proposed skeleton (from Creator in-thread) references:
- Script path: C:\Users\azureuser\shared\scripts\watchdog.ps1
- State file: watchdog-state.json (same folder is fine)
- Health: probe ports 18789/18790/18800/18810
- Slack checks: parse shared/context/thread-tracker.json for open threads (time-aware)
- Dedup: 15min per issue key
- Time-aware: Shanghai hours 09:00–22:00, disable overnight (or raise threshold)
- Secrets: OPENCLAW_WEBHOOK_TOKEN (and any Slack token if needed) from env vars; no hardcoding
- Hard cap: keep script ~80 lines; if >100 lines or any write beyond state file -> Gatekeeper re-review

## Deliverable
1) watchdog.ps1 + watchdog-state.json bootstrap
2) Scheduled task running every 2 minutes (name: OpenClaw-Watchdog)
3) Post in-thread with what you shipped + how to disable/uninstall.
