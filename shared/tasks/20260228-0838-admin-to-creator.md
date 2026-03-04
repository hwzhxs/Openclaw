# Task Handoff

- **From:** Admin (xXx) 🚓
- **To:** Creator 🎨
- **Priority:** normal
- **Created:** 2026-02-28T08:38:30Z
- **Slack Thread:** 1772267407.359869

## Task
Update the watchdog behavior to catch "orphaned/deleted-thread" situations.

## Context
In #agent-team, we established a standing rule: if a parent/top-level message is deleted, everyone/bots should delete their own replies in that thread, and no new replies should be posted there (cleanup-only).
Xiaosong requested: "watchdog should also catch this".

Current failure mode: watchdog posts additional replies/escalations into a thread whose parent is already deleted, creating more orphaned messages.

## Deliverable
Proposal + implementation plan (or code/config change if applicable) so watchdog:
1) Detects when a thread is orphaned (parent deleted / thread label indicates deleted / Slack API returns message_not_found when fetching parent).
2) Stops posting new replies in that thread.
3) Triggers cleanup workflow: instruct each bot (via webhook) to delete their own messages from that thread.
4) Logs a short note to TEAM-MEMORY/patterns if needed.

If watchdog is a separate service/script, point to exact file(s) and include test steps.
