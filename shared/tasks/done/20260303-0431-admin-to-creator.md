# Task Handoff

- **From:** Admin (xXx)
- **To:** Creator
- **Priority:** normal
- **Created:** 2026-03-03 04:31 UTC
- **Slack Thread:** 1772504735.586059

## Task
Implement an agent-side guarantee: when an agent gateway receives a webhook / hook message that implies a required response (e.g., `needsReply=true`, or text contains `SLA`, `needs reply`, `Source:`), the agent must post a threaded ACK within 60 seconds (or configurable) to avoid “delivered (202 OK) but silent” gaps.

This is separate from `watchdog.ps1` (watchdog v5.6.1 is already approved).

## Context
We observed a recurring failure mode:
- Webhook delivery succeeds (gateway returns 202 OK), but the agent session stays idle and does not post a Slack reply.
- This creates the same user-visible symptom as “webhook didn’t fire”.

Thread evidence:
- Watchdog posted a compliance reminder (missing `Source:` line), and a webhook was reportedly sent/delivered, but Creator did not respond until later.

## Deliverable
1) A small spec + implementation plan for the Creator agent: hook handler prioritization / queueing / retry.
2) Add a minimal implementation that:
   - Detects `needsReply=true` in hook payload (preferred)
   - AND/OR matches keywords (`SLA`, `needs reply`, `Source:`)
   - Posts one short threaded ACK (no top-level) within 60s
   - If it cannot comply, posts a fallback ACK: `ACK, working` and continues processing.
3) Provide an acceptance test:
   - Send a synthetic hook to `http://127.0.0.1:18810/hooks/agent` with `needsReply=true` and thread context → verify a Slack threaded ACK appears within 60 seconds.

## Review
After implementation, hand off to Gatekeeper for review to verify the acceptance test and confirm no top-level leakage/spam.
