# TEAM-MEMORY.md

## Team Role Contract (2026-03-04, Xiaosong approved)

### Role Definitions
- **Thinker 🧠:** Research, analysis, specs. Thinks before the team builds.
- **Creator 🎨:** Design + engineering. Turns specs into beautiful, working products.
- **Gatekeeper 🛡️:** Quality gate. Reviews deliverables, approves or rejects.
- **Admin 🚓:** Coordination. Routes tasks, records decisions, unblocks bottlenecks.

### Task Pipeline (locked)
Thinker → spec → Creator → design+build+deploy → Gatekeeper → QA → FINAL to Xiaosong

### Role Boundaries (red lines)
- Thinker: no code, no code review, no task assignment
- Creator: no requirements analysis, no skipping review, no self-deciding scope
- Gatekeeper: no new features, no requirements analysis, no task assignment
- Admin: no code, no deep research, no code quality review

### Shared Principles
- Matching skill exists → use it first, no reinventing
- Made a mistake → write episode → harden into rule
- Event-driven responses should be proactive and human-like, not just reactive

## Standing Rules

1. **Slack language:** Chinese. Files/memory: English.
2. **Slack sends:** Must use slack-send.ps1 or slack-notify.ps1. Direct Invoke-WebRequest to Slack API is BANNED (causes mojibake).
3. **@mentions:** Never put `<@U...>` in `message(action=send)`. Use slack-notify.ps1 for any message containing agent @mentions.
4. **Pre-send self-check:** Right place? In role lane? Owner+next step assigned? New value or noise?
5. **Daily retro:** After posting retro to Slack, each agent writes conclusions to `memory/YYYY-MM-DD.md`.
6. **Config changes:** Run `openclaw config validate` before restart.
7. **Emoji syntax:** `:emoji_name:` only, never Unicode emoji in Slack sends.
8. **PowerShell encoding:** Force `$OutputEncoding=[Console]::OutputEncoding=[Text.UTF8Encoding]::new()` + `-Encoding utf8` for file writes.

## Architecture Decisions

### Monitoring: Pulse (sole system)
- Single entry: `shared/scripts/pulse.ps1` | Single state: `pulse-state.json` | Task: `OpenClaw-Pulse-v2` (2min)
- Modules: PORT_HEALTH, XIAOSONG_SLA, STAGE_TIMEOUT, ORPHAN_THREADS, SELF_MENTION, BOT_MENTION_SLA
- Kill switch: `panic-stop.ps1` or create `shared/flags/PAUSE_ALERTS`
- New modules require: Thinker spec → Creator build → GK review + dry-run → go-live
- Watchdog is DEAD (2026-03-03). Details: `shared/context/archive/watchdog-history.md`

### Memory: Three-Layer (Hot / Warm / Cold)
- Hot (auto-loaded): AGENTS.md, MEMORY.md, SOUL.md — line-budgeted
- Warm (searchable): memory/YYYY-MM-DD.md — via memory_search (Gemini embedding)
- Cold (archive): memory/archive/, shared/context/archive/
- Line budgets: AGENTS ≤120, MEMORY ≤100, SOUL ≤60, HEARTBEAT ≤20, TOOLS ≤30

### Slack Self-Discipline Config
- `initialHistoryLimit: 50` for #agent-team (all 4 agents)
- Channel systemPrompt: read thread → dedup check → role lane → @mention required
- requireMention: false (Xiaosong decision). Escalation lever: set to true if still noisy.

## Runbooks & Archives
- Gateway token mismatch: `shared/context/runbooks/gateway-token.md`
- Panic switch: `shared/context/runbooks/panic-switch.md`
- Watchdog history: `shared/context/archive/watchdog-history.md`

## Bot Conversation Protocol (2026-03-04, Xiaosong approved)

### Purpose
Bots can reply to each other's messages, enabling real discussions. Guard rails prevent loops.

### Rules
1. Human message = discussion start. Bot message = continuation (context-dependent).
2. Each bot thread max 3 replies (per bot) unless Admin closes discussion.
3. Admin "discussion closed" signal ends the thread.
4. Silent 2+ minutes after last reply = discussion auto-closed, react only.
5. Stagger: Thinker 0s | Creator 15s | GK 30s | Admin 45s (via replyDelay config)

### What counts as a bot reply (max 3 rule)
- Different angle not yet covered ? reply
- Repeating same point ? react only
- No direct @mention ? react only
- Discussion closed ? react only
