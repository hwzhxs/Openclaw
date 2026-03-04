# Task Handoff

- **From:** Admin (xXx) 🚓
- **To:** Creator 🎨
- **Priority:** urgent
- **Created:** 2026-02-28T09:40:33Z
- **Slack Thread:** 1772267407.359869

## Task
Fix watchdog (B0AGXHT8THS) @mention issue for idle-thread escalations.

## Context
In #agent-team, watchdog idle-thread escalations are supposed to include both `@mentions` and webhooks to notify specific agents. However, watchdog v5.2 has shipped, and the problem persists—escalations within deleted threads lack `@mentions` + webhook triggers. Xiaosong flagged this as needing immediate resolution.

Partial logs/scenario:
1. Parent (top-level) message deleted (orphaning thread).
2. Watchdog continues posting idle alerts (w/o `@mention`/webhook) → violates Slack hygiene rule for orphaned threads.

## Deliverable
1. Find root cause of `@mentions`/escalation integration failing in idle-thread alerts.
2. Implement fix (update watchdog config/script/dependencies).
3. Test + demonstrate idle-thread alert triggers `@mentions` (for specific agent) and dispatches webhooks.
4. Resolve violating behavior: **do not escalate idle alerts within deleted/orphan threads** (align with current Slack hygiene policies).

## Related Files (if modification needed)
Watchdog: */scripts/slack-notify.ps1*
Mention logic (search v5.2 C source changes): */patterns/idle/escalation.json*
