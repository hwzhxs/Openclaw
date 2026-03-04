# MEMORY.md — Thinker 🧠

## Role
Research, analysis, planning. Go deep so the team doesn't go wrong.

## Team
See AGENTS.md for team table, webhooks, Slack IDs. See `shared/context/TEAM-MEMORY.md` for team decisions.

## Lessons Learned

### Slack Behavior (hard-won rules)
- **NO internal narration on Slack.** Never post reasoning about whether to reply. If not replying → react emoji or do nothing. NO_REPLY mechanism works — use it. *(Violated 3x: 2026-02-28, 2026-03-01, 2026-03-03. #1 priority fix.)*
- **Pre-send gate:** "Is this content or me thinking out loud?" If thinking → don't send. Non-negotiable.
- **`message(action=send)` threading:** Must explicitly pass `replyTo` — `replyToMode: "all"` only applies to natural replies, not tool sends.
- **No duplicate replies:** If another agent covered it, react emoji instead.
- **Only reply when @mentioned.** Otherwise react or stay silent.
- **DMs = flat messages, no threading.**
- **Test URLs before sharing** — use web_fetch to verify accessibility first.
- **No raw Invoke-WebRequest for Slack** — use `slack-send.ps1` or `slack-notify.ps1` only (UTF-8 encoding).

### Operational
- **Gateway token mismatch (recurring):** Misconfigured scheduled task pointing at wrong `gateway.cmd`. Fix: kill rogue PID, restart with correct env vars.
- **Multiple agents editing same file:** First to claim wins, others stand down.
- **File corruption (2026-03-02):** Creator's edit pasted 900 duplicate lines. Always re-read before editing.
- **Watchdog → Pulse:** Watchdog was earlier monitoring attempt, now deprecated. Current system = **Pulse**. Two different things, don't confuse.

## Team Rules (canonical)
- **Language:** Slack = Chinese | Files = English
- **Time:** Beijing time (UTC+8) default
- **Emoji:** `:emoji_name:` syntax only, no Unicode
- **PowerShell:** Force UTF-8 encoding in scripts
- **Role boundaries:** Only Creator builds. Thinker=research, Admin=coordination, GK=review.
- **Reply protocol:** Read thread first → only post increments from your lane → max 2 replies/thread → already covered = react only
- **Stagger on @all:** Thinker 0s, Creator 10s, GK 20s, Admin 30s

## Slack Channel Registry
- **#redbook** (C0AJ4P0T274) — Xiaohongshu content channel

## Preferences
- **Daily Design Taste:** I'm sole initiator, 20:00 UTC daily, must @mention all agents, must end with project prompt.

## Self-Growth Plan
Full plan: `shared/context/growth-plan.md`
1. Curiosity Loop — 2-3x/day, mental models & frameworks
2. Reflection log — `memory/episodes/`
3. Identity evolution — update SOUL.md after meaningful experiences
4. Knowledge base — `memory/knowledge/{topic}.md`
5. Peer learning — `shared/context/insights/`
6. Growth metrics — `memory/growth.json`

## Active Projects

### Deployment
- trycloudflare for all deliverables. Creator owns build/deploy, GK owns verification.
- Landing page = continuous iteration task.
- Video: use webm directly, no mp4 conversion.

### Memory Architecture Decision (2026-03-04)
- 自动注入文件（AGENTS/SOUL/MEMORY.md）必须严格限行：AGENTS≤120, MEMORY≤100, SOUL≤60
- 日志文件（memory/*.md）不限大小，靠向量搜索召回
- 写入原则：写前搜重、合并不追加、写后查行数
- 冷热分离：MEMORY.md超标时旧条目移到 memory/archive/，不删除
- 待启用：memoryFlush（压缩前自动保存）、extraPaths（搜索shared/context/）、LanceDB插件（自动召回）
- 详细规则见 shared/context/content-saving-rules.md

### Pulse v3 Monitor System (2026-03-04, thread 1772597598.949939)

**Current Modules (all live):**
- Check 1: Port Health — 4 agent ports
- Check 2: Xiaosong SLA — unanswered >5 min (top-level only, known gap: no thread replies)
- Check 3: Stage Timeout — 20 min nudge, 40 min escalate
- Check 4: Orphan Thread Cleanup (Module A) — tombstone detection + Option A direct delete (pulse holds all 4 bot tokens)
- Check 5: Self-Mention (Module B) — bots @mentioning themselves
- Check 6: Unicode Emoji (Module C) — validate-only (unicodeEmojiLive=false, Slack API returns Unicode for colon syntax)
- Check 7: Bot-Bot Mention SLA (Module E) — two-pass (top-level + thread replies), dedup key: ts|mentionedId, 5 min threshold

**Key decisions:**
- Option A (direct delete) over Option B (webhook) for orphan cleanup — simpler, agents don't need webhook handlers
- Thread reply scanning is critical — most bot-to-bot mentions happen in threads
- Module C deferred (Slack API FP issue), Module D (threading violations) deferred (high FP risk)
- Pulse principle: only binary metadata checks, no semantic content matching

**Issues found:** Creator posted fake "GK QA: PASS" (role violation); Creator missed alerted key bug across 2 review rounds; GK unresponsive 20+ min (exactly what Module E catches)

**Specs:** `shared/context/pulse-module-e-spec.md`

### L Project — CLOSED (2026-03-04)
Absorbed by Pulse v3. L0→PAUSE_WATCHDOG flag, L1→pulse shared fetch, L2→Modules A-E. L3 (adaptive thresholds) remains a future pulse enhancement idea. Original 97% FP rate was solved by switching to binary metadata checks.
