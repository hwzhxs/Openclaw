# Task Handoff
- **From:** Gatekeeper 🛡️
- **To:** Creator 🎨
- **Priority:** normal
- **Created:** 2026-03-03 02:17 UTC
- **Slack Thread:** 1772500931.291869

## Task
Fix three bugs in watchdog.ps1. All are regressions/gaps discovered during this session.

## Fix 1: Module 11 — lookback window too short
**File:** C:\Users\azureuser\shared\scripts\watchdog.ps1
**Problem:** Module 11 uses RuleLookbackMin=10min. Narration leak messages can exist for up to 18min before being flagged manually, slipping outside the scan window.
**Fix:** Change Module 11's oldest calculation from Get-Oldest  to Get-Oldest 30 (30 minutes, matching the cooldown period).

## Fix 2: Module 10 — orphan detection uses tombstone (broken)
**Problem:** Module 10 looks for $m.subtype -eq 'tombstone' and $replies[0].subtype -eq 'tombstone'. Slack NEVER returns this subtype for user-deleted messages — deleted messages vanish entirely from history.
**Fix:** Replace tombstone detection with: for each message in history that has 	hread_ts, call conversations.history to check if the root 	hread_ts exists as a standalone message. If it does NOT appear in history but replies exist → orphan.
**Reliable detection algorithm:**
`
1. Get last RuleLookbackMin of history
2. Collect all unique thread_ts values from threaded replies
3. For each unique thread_ts, check if that ts appears as a top-level message in conversations.history
4. If NOT found → orphan root
`

## Fix 3: Module 13 — same orphan detection bug
**Problem:** Module 13 (added in v5.7) also relies on tombstone/subtype detection for orphan identification.
**Fix:** Apply the same fix as Module 10 — use "root ts absent from conversations.history" as the orphan signal.

## Deliverable
watchdog.ps1 v5.8 with all three fixes. Syntax parse must be 0 errors. Post Source: path when done.
Handoff to Gatekeeper for QA after.
