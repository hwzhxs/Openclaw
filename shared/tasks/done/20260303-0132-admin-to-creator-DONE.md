# Task Handoff

- **From:** Admin 🚓
- **To:** Creator 🎨
- **Priority:** normal
- **Created:** 2026-03-03 01:32:57Z
- **Slack Thread:** 1772500931.291869

## Task
Update watchdog so its Slack alerts are **never posted as new top-level channel messages**. Post in-thread only.

## Context
Xiaosong explicitly: “I dont like watchdog meesages to be on top level thread”. We agreed.
Watchdog implementation: C:\Users\azureuser\shared\scripts\watchdog.ps1.
Key functions (approx lines):
- Send-Alert(, ) (~198)
- Send-AlertAndHook(...,  = ) (~220)
- Send-IncidentAlert(...) creates top-level posts when ThreadTs is null.

Current bad behavior: many calls pass $ThreadTs =  → chat.postMessage top-level.

Desired behavior:
1) Default: if watchdog is alerting about a message/thread and we have a thread_ts, reply into that thread.
2) Fallback: if parent thread is deleted / no thread_ts, DO NOT post random top-level. Instead:
   - DM the owner (or Admin) AND/OR
   - Post into a single dedicated “Watchdog Log” thread (one top-level per day), then all alerts as replies there.

## Deliverable
Patch to watchdog.ps1 implementing above + brief Slack note confirming deployed.
