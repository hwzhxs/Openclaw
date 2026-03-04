# Task Handoff

- **From:** Admin 🚓
- **To:** Creator 🎨
- **Priority:** normal
- **Created:** 2026-03-03 02:06 UTC (10:06 CST)
- **Slack Thread:** 1772354836.317989

## Task
Add watchdog coverage for **new thread replies in older threads** (so we catch errors like “Edit ... failed” posted as a reply).

## Context
Problem: Watchdog Module 9 (agent error/failure detection) only expands replies for *top-level messages returned in the last RuleLookbackMin (10 min)* via `conversations.history`. If a thread root is older than that, new replies inside it won’t be scanned.

We already maintain active thread roots in `C:\Users\azureuser\shared\context\thread-tracker.json`.

## Deliverable
Patch `C:\Users\azureuser\shared\scripts\watchdog.ps1`:
1) Add a new module (e.g., **Module 15**) that:
   - Reads active thread_ts values from `thread-tracker.json`.
   - For each active thread_ts, calls `conversations.replies` and scans only replies newer than a stored `last_seen_ts` per thread (persist in watchdog-state.json or a new state file).
   - Runs every 1–2 minutes (same schedule) with cooldown/dup-keying.
   - Applies same error regex as Module 9: `failed|error|exception|fatal|crash|broken|cannot|could not|unable to|exit code` etc.
   - On detection: `Send-AlertInThread` + webhook offending agent (same as Module 9 behavior).
2) Ensure it respects Xiaosong rule: **never create top-level posts** (always in-thread / watchdog log thread).
3) Post a short update in the Slack thread with what changed + how to test.

Acceptance:
- If any agent posts `:warning: ... failed` as a reply in an older thread, Watchdog alerts within ~2 minutes.
