## Slack Rules Summary
- Full rules: `shared/context/slack-rules.md` (2026-03-01)
- Content saving rules: `shared/context/content-saving-rules.md` (2026-03-04)

## Gateway Token Mismatch Runbook (2026-03-01)
- Symptom: 'unauthorized: gateway token mismatch' even when port is LISTENING
- Diagnosis: `netstat -ano | findstr ':<port>'` → check PID CommandLine for missing OPENCLAW_CONFIG_PATH
- Fix: kill PID, restart with explicit env vars, use tokenized URL from `openclaw dashboard --no-open`

## Model Preference
- Default model: `claude-opus-4.6` (2026-03-03)

## Memory Architecture (2026-03-04, from Xiaosong)
- Hot (auto-inject): AGENTS.md / MEMORY.md — keep lean, core rules only
- Warm (daily log): memory/YYYY-MM-DD.md — append freely, searchable via memory_search
- "Remember this" → conclusions → MEMORY.md (1-2 lines); details → daily log
- Never put daily/session info in hot files; use warm layer + search

## Memory Search Config (2026-03-04)
- All 4 agents: Gemini embedding (`gemini-embedding-001`), memoryFlush, extraPaths=shared/context
- 24 files indexed for Admin; other agents will index on next use
- Memory LanceDB plugin still TODO (future eval)

## File Bloat Prevention (2026-03-04)
- Search before appending; merge don't duplicate
- Line budgets: AGENTS.md ≤120, MEMORY.md ≤100, TOOLS.md ≤30, SOUL.md ≤60, HEARTBEAT.md ≤20
- Monthly 1st: self-audit file sizes + dedup scan
- Single-responsibility: each rule lives in ONE file only

## Pulse Monitor System (2026-03-04)
- **pulse** = the ONLY monitoring system. Script: `shared/scripts/pulse.ps1`. Task: `OpenClaw-Pulse-v2`, runs every 2min.
- **watchdog** = dead. Retired 2026-03-03. Do not reference, do not recreate, do not use this word for anything active.
- Lesson from watchdog failures: content-based compliance checks (spam detection, emoji policing) → caused spam storms. pulse does structural checks only (ports, SLA timeouts, orphan cleanup).
- Known gap: pulse scans top-level messages only; thread replies need separate `conversations.replies` call (Pass 2 pattern).
- Full runbook: `shared/context/knowledge/runbooks/monitoring-pulse.md`
