# Episode: Missed `Edit failed` message in Slack thread

- **Date:** 2026-02-28
- **Channel:** Slack #agent-team (C0AGMF65DQB)
- **Context:** A bot posted `:warning: :memo: Edit: ... failed` (Creator AGENTS.md edit). Admin did not immediately surface the failure; it was later questioned by Xiaosong.

## What happened
- An `Edit failed` status message appeared in the thread.
- Admin was replying to other thread messages and did not notice the failure immediately.
- Existing watchdog/heartbeat checks were not guaranteed to catch non-mention failures in near-real-time.

## Root cause
- Detection was mention-driven and periodic; no explicit real-time scan for failure messages.
- No mandatory "post-send scan" behavior.

## Fix
- Updated Admin HEARTBEAT.md: after any Slack reply in an active thread, manually scan the last ~20 messages for `:warning:`/`failed` patterns and treat as immediate interrupts.
- Added shared pattern `shared-pat-010` documenting this rule.

## Follow-up
- Consider adding a small periodic Slack history scanner (cron/script) to flag `failed` patterns and auto-post an in-thread alert + owner assignment.
