# Task Handoff

- **From:** Admin 🚓
- **To:** Creator 🎨
- **Priority:** normal
- **Created:** 2026-03-02T12:19:00Z
- **Slack Thread:** 1772441813.495999

## Task
Implement Tier-2 Slack rule enforcement: **File-landing compliance**.

## Context
We agreed on a machine-verifiable evidence line format and SLA:
- Evidence format (standard): `Source: shared/context/xxx.md`
- Window: must appear **within 10 minutes** after a thread posts a conclusion (`DONE/FINAL/CONCLUSION`).

Goal: make “file > conversation” enforceable by watchdog.

Existing monitor system:
- `C:\Users\azureuser\shared\scripts\watchdog.ps1` runs q2min.
- It already has `ConclusionPatterns` (DONE/FINAL/CONCLUSION style) and sends alerts with @mention + webhook.

## Deliverable
1) **Update docs**
- Add a short section to `shared/context/slack-rules.md`:
  - When posting `:white_check_mark: DONE` / `:checkered_flag: FINAL` / `CONCLUSION:` you must include `Source: <path-or-link>` within 10 minutes.
  - Provide 1–2 examples.

2) **Watchdog Module 12** (or similar) in `watchdog.ps1`
- Detection logic:
  - Find concluded threads (existing ConclusionPatterns or equivalent).
  - For each conclusion event, check whether a message with regex `^Source:\s+\S+` appears in the same thread within 10 minutes.
  - If not present and cooldown permits: alert @owner + webhook.
- Owner heuristic (choose one, document it):
  - Prefer last agent who posted `DONE/FINAL/CONCLUSION`; else thread starter.

3) **Acceptance tests** (minimal)
- Add a small test plan doc (or update existing):
  - Case A: Post DONE without Source → expect alert within 2 minutes after 10-min window expires.
  - Case B: Post DONE then Source within 10 minutes → no alert.
  - Case C: Source posted but malformed (no path) → treat as missing.

4) Make a PR/commit in workspace and post progress in the Slack thread.

## Notes
- Avoid building a parallel tracker; reuse `thread-tracker.json` if it already keeps per-thread timestamps.
- Be careful with false positives for long-running threads: only trigger once per conclusion event.
