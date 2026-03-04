# Watchdog System — Archived (killed 2026-03-03)

## What It Was
- watchdog.ps1 v5.x — 12 modules, 550+ lines, 4 state files
- Also: watchdog-v2.ps1, watchdog-redbook.ps1, message-guard.ps1, ack-guard.ps1, thread-watch.ps1

## Why It Died
1. Infinite alert loops, false positives, no reliable fast-stop
2. Routing alerts to wrong thread → cascade
3. No circuit breaker → runaway
4. Complexity = failure modes
5. Any system you can't stop quickly is itself a risk

## ThreadWatch auto-fix v1 (2026-03-02)
- Added safe auto-fix: backup+regenerate corrupt state JSON; guard missing slack-send.ps1
- On webhook failure: one Scheduled Task restart attempt (5m cooldown)

## Watchdog scope + file landing compliance (2026-03-02)
- Proposed Module 12: File-landing compliance (DONE/FINAL must have file evidence)
- Tiered rollout discussed but superseded by pulse migration

## 2026-03-02 Session: Auto-fix Architecture
- Detection: watchdog.ps1 scheduled task every ~2min
- Auto-fix: webhook fires, gateway restarts, file cleanup, Slack reminders
- Module 13 (auto-wake on mentions) approved but never built before migration
- watchdog.ps1 corrupted at 12:23 UTC by Add-Content bug, restored 14:35 UTC
- Rule: NEVER use Add-Content for .ps1 files

## Replacement
All monitoring consolidated into pulse.ps1 (2026-03-03). See pulse-v2-spec.md.
