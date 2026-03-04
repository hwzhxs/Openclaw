# Monitoring (Pulse) — Canonical Memory + Runbook

**Canonical file:** this document is the single source of truth for our monitoring system history and operating notes.

- **System:** Pulse (PowerShell)
- **Current script:** `C:\Users\azureuser\shared\scripts\pulse.ps1`
- **Scheduled task:** `OpenClaw-Pulse-v2` (every 2 min, SYSTEM, `powershell.exe` / PS5.1)
- **State:** `C:\Users\azureuser\shared\scripts\pulse-state.json` (single file; atomic writes; auto-prune)
- **Rules source:** `shared/context/slack-rules.md` (§8, §11, §12)

---

## 0) Why Pulse exists (problem statement)
Old watchdog-based monitoring became too complex and too buggy (multiple scripts, multiple state files, backup explosions, false positives, hard debugging). Xiaosong requested a clean reset: analyze requirements first, then build a minimal reliable system.

---

## 1) Requirements (derived from slack-rules.md)
We only monitor what is:
- **Externally observable**, and
- **Time/SLA or infra health** (not subjective behavior policing), and
- **Low false-positive**.

### In scope (what Pulse MUST monitor)
1. **PORT_HEALTH** — 4 agent ports: `18789/18790/18800/18810`
2. **XIAOSONG_UNANSWERED** — Xiaosong top-level message has no reply after **5 minutes**
3. **FILE_LANDING_SLA** — any `DONE/FINAL/CONCLUSION` must have `Source: <path>` within **10 minutes**
4. **STAGE_TIMEOUT** — pipeline stall: **15m nudge**, **30m escalate** (per-thread cooldown; max-age guard)

### Explicitly out of scope (undetectable / too noisy)
- Proving agents performed the pre-send gate (reading last 5 msgs)
- Detecting whether a webhook fired after an @mention (Slack API can’t see this)
- Staggered delay enforcement / role-lane policing
- Keyword-based “error detection” in free text

---

## 2) Design principles (non-negotiable)
1. **One script, one scheduled task, one state file**
2. **Atomic state writes** (`.tmp` → rename), no `.bak` proliferation
3. **Alert on state-change / per-message once** (no spam loops)
4. **PS5.1 compatible** (no PS7-only features)
5. **No auto-heal loops** (alerting > unsafe retry storms)
6. **State corruption handling:** delete/rebuild defaults

---

## 3) Current behavior (Pulse v5)
### Checks
- PORT_HEALTH: state-change alerts (UP→DOWN, DOWN→UP)
- XIAOSONG_UNANSWERED: once per message; alert memory pruned at 2h
- FILE_LANDING_SLA: once per conclusion message; SLA=10m
- STAGE_TIMEOUT: uses stage markers; excludes `DONE/FINAL/NUDGE/ESCALATE` to prevent loops

### Known limitation (accepted)
- Xiaosong SLA currently scans **top-level** channel messages via `conversations.history`. Xiaosong thread-only posts are not covered (v6 backlog).

---

## 4) QA history (what broke + what fixed it)
Key lesson: **PS5 compatibility** is the #1 failure mode.
- Rejected: `#Requires -Version 7.0`
- Rejected: `ConvertFrom-Json -AsHashtable` (PS6+)
- Rejected: PS5 can’t use `if` as an expression inside a cast
- Fixed: replace with PS5-safe helpers (`ConvertTo-Hashtable`, epoch math, list initialization via `New-Object` + `.Add()`)
- Fixed: remove `DONE/FINAL` from stage markers to avoid false nudges

---

## 5) Migration / cleanup backlog
### Monitoring docs consolidation (THIS file is canonical)
- Keep: `shared/context/knowledge/runbooks/monitoring-pulse.md` (this file)
- Older duplicates should become pointers (do not keep multiple “truth” files).

### Old watchdog artifacts
- Old scripts/state exist under `shared/scripts` + `shared/context` (watchdog.ps1, thread-watch.ps1, watchdog-*.json, etc.).
- Cleanup should be done after confirming Pulse stable (archive first; then delete).

---

## 6) v6 improvements (optional)
- Add scanning of Xiaosong thread replies for unanswered SLA
- Add Pulse self-heartbeat timestamp + staleness alert (monitor-alive)
- Add scheduled-task last-run validation (detect task disabled)
