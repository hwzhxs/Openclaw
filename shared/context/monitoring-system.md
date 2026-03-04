# monitoring-system.md — Full Monitor Discussion Record

Last updated: 2026-03-04

---

## Current System: pulse.ps1 v5 (FINAL, 2026-03-02)

- **Script:** `C:\Users\azureuser\shared\scripts\pulse.ps1`
- **Scheduled Task:** `OpenClaw-Pulse-v2` — every 2 min, `powershell.exe` (PS5 compatible)
- **State file:** `C:\Users\azureuser\shared\scripts\pulse-state.json`

### 4 Checks
1. **PORT_HEALTH** — TCP ports 18789 / 18790 / 18800 / 18810 (all 4 agents)
2. **XIAOSONG_UNANSWERED** — message unanswered >5 min → alert
3. **FILE_LANDING_SLA** — `Source:` path response within 10 min of DONE/FINAL event
4. **STAGE_TIMEOUT** — 15 min nudge, 30 min escalate

### Design Rules
- 1 script, 1 state file
- State-change alerts only (no repeated noise)
- PS5 compatible
- No auto-heal
- No .bak files

### Why We Replaced watchdog.ps1
watchdog.ps1 v5.5 was 12 modules, 550+ lines, 4 state files — too complex, too buggy.
Root cause of the v5.8 infinite loop: Module 3 routed stuck-thread alerts to `$ts`
(the stuck thread's own timestamp) → posted top-level → Rule A detected as violation
→ new top-level alert → infinite cascade.

---

## Watchdog Panic Switch (3-Layer Emergency Stop)

### Layer 1: Slack command
- `!stop` / `!resume` in #agent-team
- Module 0 scans messages; ONLY Xiaosong's commands count
- On stop: reacts `:octagonal_sign:`

### Layer 2: Scripts
- `C:\Users\azureuser\shared\scripts\panic-stop.ps1`
- `C:\Users\azureuser\shared\scripts\panic-resume.ps1`

### Layer 3: Flag files
- `C:\Users\azureuser\shared\flags\PAUSE_WATCHDOG` — watchdog checks at startup, exits if present
- `C:\Users\azureuser\shared\flags\PAUSE_ALERTS`

### Circuit Breaker
Max 25 Slack posts / 5-min rolling window — auto-sets PAUSE_WATCHDOG flag if exceeded.

### Key Design Principle
> Any monitoring/automation system MUST have a fast-stop mechanism.
> A system you cannot quickly stop is itself a risk.

---

## History: watchdog.ps1 → pulse.ps1

| Version | Status | Notes |
|---|---|---|
| watchdog.ps1 v5.5 | Killed (2026-03-02) | 12 modules, 550+ lines, 4 state files, too complex |
| watchdog.ps1 v5.8 | Killed | Fixed loop bug but still overly complex |
| pulse.ps1 v5 | Current (FINAL) | Lean, 4 checks, 1 state file |

---

## Confirmed by Xiaosong
- pulse.ps1 v5 design: 2026-03-02
- Panic switch 3-layer mechanism: 2026-03-03
