# File-Landing Compliance — Acceptance Test Plan

**Feature:** Module 12 (watchdog.ps1) + slack-rules.md Section 12
**Author:** Creator
**Date:** 2026-03-02

---

## Overview

After any agent posts a conclusion message (`:white_check_mark: DONE`, `:checkered_flag: FINAL`, `CONCLUSION:`), they must include a `Source: <path>` evidence line within **10 minutes** in the same thread. Module 12 enforces this via the watchdog.

---

## Test Cases

### Case A: DONE without Source → expect alert after 10-min window

**Setup:**
1. An agent posts `:white_check_mark: DONE: [any text]` in a thread.
2. No `Source:` reply follows.

**Expected behavior:**
- Watchdog detects the conclusion and opens a SLA window entry in `file-landing-sla.json`.
- After 10 minutes pass (and on the next watchdog run ≥2 min after that), a Slack alert fires in the same thread:
  ```
  :warning: Watchdog: @<agent> posted a conclusion Xmin ago but no `Source: <path>` evidence line found in thread. Please reply with `Source: <path>` to confirm the file was written.
  ```
- Alert is fired only once (cooldown 15 min via watchdog-state.json) — not on every run.
- Admin webhook is also fired.

**Pass criteria:**
- Alert appears in thread within 2 watchdog cycles after the 10-min window expires.
- Alert contains the agent @mention.
- Alert is in-thread (not top-level).

---

### Case B: DONE then Source within 10 minutes → no alert

**Setup:**
1. An agent posts `:white_check_mark: DONE: [any text]` in a thread.
2. Within 10 minutes, the same thread receives a message containing `Source: shared/context/slack-rules.md`.

**Expected behavior:**
- Watchdog detects the `Source:` reply and marks `evidenceFound = true` in `file-landing-sla.json`.
- No alert is fired for this conclusion event.

**Pass criteria:**
- No `:warning: Watchdog:` message appears in that thread for this conclusion.
- `file-landing-sla.json` shows `evidenceFound: true` for the conclusion key.

---

### Case C: Source posted but malformed (no path) → treated as missing

**Setup:**
1. An agent posts `:white_check_mark: DONE: [any text]` in a thread.
2. Within 10 minutes, a reply contains `Source:` (with nothing after it, or only whitespace).

**Expected behavior:**
- Module 12 applies the regex `^Source:\s+\S+` — requires at least one non-whitespace character after `Source:`.
- A bare `Source:` or `Source: ` does NOT satisfy the evidence check.
- After 10 minutes with no valid evidence, the alert fires as in Case A.

**Pass criteria:**
- `evidenceFound` remains `false` when only malformed `Source:` is present.
- Alert fires after 10-min window.

---

## Verification Steps

```powershell
# Check SLA state after a test run
Get-Content "C:\Users\azureuser\shared\context\file-landing-sla.json" | ConvertFrom-Json

# Manually trigger watchdog to test without waiting
& "C:\Users\azureuser\shared\scripts\watchdog.ps1"

# Check watchdog state for Module 12 alerts
Get-Content "C:\Users\azureuser\shared\scripts\watchdog-state.json" | ConvertFrom-Json |
    Select-Object -ExpandProperty PSObject |
    ForEach-Object { $_.Properties } |
    Where-Object { $_.Name -match "fileland_" }
```

---

## Edge Cases

| Scenario | Expected behavior |
|---|---|
| Conclusion posted by non-agent (Xiaosong) | No alert — owner must be an agent (AgentBotUserIds check) |
| Same thread has multiple conclusions | Each conclusion gets its own SLA key (`threadTs_conclusionTs`); tracked independently |
| Evidence added after alert fired | `evidenceFound` is updated to `true`; no further alerts |
| Thread deleted before 10-min window | Watchdog won't find replies; entry stays open but no harm |
| Watchdog restarts mid-window | State loaded from `file-landing-sla.json`; window resumes correctly |

---

## Files Modified

| File | Change |
|---|---|
| `shared/context/slack-rules.md` | Added Section 12: File-Landing Compliance |
| `shared/scripts/watchdog.ps1` | Added Module 12 (file-landing SLA enforcement) |
| `shared/context/file-landing-sla.json` | Created at runtime by watchdog (SLA state) |
| `shared/context/file-landing-test-plan.md` | This file |
