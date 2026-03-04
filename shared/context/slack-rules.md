# Slack Rules (Single Source of Truth)

All agents MUST read this before ANY Slack send. No exceptions.

## 0. Mandatory Pre-Send Gate (ALL agents, ALL threads)

Before composing ANY text message in Slack:

1. **Read the last 5 messages in the current thread** — `message(action=read, threadId=<current>, limit=5)`
2. **Check for your own undeleted violations** — if found, delete them before sending anything
3. **Emoji format: use `:emoji_name:` Slack syntax ONLY** — NEVER paste Unicode emoji directly (causes garbled text). Xiaosong rule 2026-03-03.
4. **PowerShell UTF-8:** All scripts sending to Slack API must force `$OutputEncoding=[Console]::OutputEncoding=[Text.UTF8Encoding]::new()` and use `-Encoding utf8` for file writes. Xiaosong rule 2026-03-03.
5. **Slack send path (NO ad-hoc IWR):** All agents MUST send Slack messages via `slack-send.ps1` or `slack-notify.ps1`. **Do NOT** call Slack Web API with raw `Invoke-WebRequest` / `Invoke-RestMethod` ad-hoc; it bypasses the UTF-8-bytes handling and causes mojibake (`???`). Xiaosong rule 2026-03-03.
3. **Check if your point is already covered** — if yes, emoji react only, do not send

This is not optional. It is structural. Skipping it is a violation in itself.

**Why:** The only reliable way to avoid posting narration/duplicates/noise is to see the thread state immediately before you post — not to "remember" a rule.

## 1. Threading

- **Thread starter = ONE short line + thread emoji.** No details, no tables, no long text.
- **ALL details, @mentions, content = thread REPLY** (use `replyTo`).
- If your message is longer than 1 line and you're about to post it as a thread starter: STOP. Make it a reply instead.

### ⚠️ HARD RULE: replyTo is MANDATORY when in a thread
- **Before every `message(action=send)`, check inbound context for `reply_to_id`.**
- If `reply_to_id` exists → you MUST pass it as `replyTo`. No exceptions.
- If you're responding to a message that's already in a thread → use the thread's parent messageId as `replyTo`.
- **Failure to do this = creating a new top-level post instead of a thread reply. This is the #1 recurring violation.**

## 2. Self-Mentions

- **NEVER @mention yourself** in your own messages. You ARE you — mentioning yourself is nonsensical.
- When relaying/forwarding messages that contain your own @mention, strip it out.

## 3. @Mentions and Webhooks

- **Bot-to-bot @mention does NOT trigger the other agent.** It's just a visual label in Slack.
- **You MUST fire a webhook** to actually trigger another agent. The @mention is for humans to see; the webhook is the real trigger.
- Webhook endpoints: see MEMORY.md or AGENTS.md for ports/tokens.

### HARD RULES: Mention + Webhook Enforcement (2026-03-03, Xiaosong confirmed)

These rules apply to ALL agents, ALL paths — bot-bot, watchdog, handoffs, everywhere. No exceptions.

- **HARD RULE 1:** Any Slack message text containing `<@U...>` MUST be sent via `slack-notify.ps1` (never `message(action=send)`). `slack-notify.ps1` auto-detects mentions and fires the corresponding agent webhooks.
- **HARD RULE 2:** Any watchdog/automation path that posts Slack and includes `<@U...>` MUST route through `Send-AlertAndHook` (single enforcement point: detect mentions → Fire-Hook). No custom one-off webhook logic.
- **HARD RULE 3 (Exception):** Direct `Fire-Hook` calls are allowed ONLY as silent, agent-directed triggers (no Slack text). These are intentional internal signals, not notifications.

**Supporting guidance:**
- Prefer `:emoji_name:` colon syntax over Unicode emoji in Slack API messages. Unicode emoji can cause encoding-related false positives in watchdog parsing (e.g. module 8 error detection).
- Audit basis: Gatekeeper confirmed all 14 watchdog modules, all `Send-AlertAndHook` calls, all `slack-notify.ps1` paths, and all direct `Fire-Hook` calls pass these rules as of 2026-03-03.

## 4. Sending Messages with @Mentions

- Use `slack-notify.ps1` script (NOT `message` tool) for any message containing `<@U...>`.
- `message(action=send)` is ONLY for messages WITHOUT @mentions.

## 5. Thread Conclusion Protocol

- When a thread discussion is complete, **Admin (U0AHN84GJGG) reacts with a check mark** on the thread starter.
- Only Admin's check react = thread closed. Others' reacts don't count as closure.
- Threads without Admin's check react = still open, need follow-up.

### Orphan Thread Cleanup (MANDATORY)
- If a thread starter / top-level message is deleted (tombstone), **all participants must delete their own replies under that deleted starter**.
- Do **NOT** post any new replies in an orphaned thread. Only delete/cleanup.
- Repost any needed content under the correct canonical thread.

## 6. Language

- **Slack chat: Chinese ONLY** (speak Chinese on Slack; English in Slack causes confusion — Xiaosong rule 2026-03-03)
- **File writes: English ONLY** (Chinese causes encoding corruption across processes)
<!-- Evolved: 2026-03-03 | source: Xiaosong @all language rule | prior: "Chinese or English OK" → "Chinese ONLY on Slack" -->

## 7. Emoji Reactions

- React to messages you've seen/acknowledged
- One reaction per message max
- Use reactions instead of low-value replies ("ok", "got it")

## 8. Direct Mentions by Xiaosong

- If Xiaosong @mentions a specific agent, ONLY that agent should reply.
- Other agents should NOT pass the message or relay it to the mentioned agent.
- Non-mentioned agents may only react with an emoji — no text replies needed.
- The mentioned agent is responsible for responding directly.

## 9. Compliance

- Admin monitors every channel message in real-time for rule violations
- If you violate a rule, Admin will flag it and ask you to fix it immediately

## 9.5 Pre-send “10s Self-Check” (2026-03-01)

Before you send ANY Slack message, take 10 seconds and check:
1) **Right place?** Thread reply vs top-level (if `reply_to_id` exists, you must use `replyTo`).
2) **Role lane?** Admin=route/monitor; Thinker=analysis/spec; Creator=build; Gatekeeper=review/QA.
3) **Owner + next step + deliverable?** If missing → ask/assign before adding content.
4) **@mention ⇒ webhook too.** Never rely on @mention alone to trigger an agent.
5) **Non-duplicative + scannable.** If it’s just repeating, prefer an emoji reaction.

## 10. @all Protocol (2026-03-01)

When Xiaosong starts a message with `@all`, follow these rules:

### Who Gets Invited
- `@all` = all 4 agents are **invited** (not obligated) to reply
- Specific `@mention` = only that agent replies; others react emoji only
- No mention, no `@all` = emoji react only, no text reply

### Staggered Delays
Absolute from the original message timestamp (not sequential):
- **Thinker**: 0s
- **Creator**: 10s
- **Gatekeeper**: 20s
- **Admin**: 30s

### Active Check (MANDATORY before composing)
1. Read ALL existing replies in the thread first.
2. If your point is already covered → react `:heavy_plus_sign:` and stay silent.
3. If you have something new from YOUR role's perspective → post it (2-3 sentences max).
4. Nothing to add? → `:heavy_plus_sign:` react only. Silence is fine.

### Role-Based Lanes
Only reply from your own role's perspective:
- **Thinker** (:brain:): analysis, tradeoffs, research, root cause
- **Creator** (:art:): implementation, how to build it, feasibility — **SOLE OWNER of all file edits and builds**
- **Gatekeeper** (:shield:): risks, quality, edge cases, what could go wrong — reviews only, never edits files directly
- **Admin** (:police_car:): coordination, next steps, decisions, summary

### File Edit Ownership (Xiaosong rule, 2026-03-03)
**Creator is the ONLY agent who writes/edits files and runs builds.**
- Thinker, Gatekeeper, Admin: NEVER directly edit scripts, configs, or code files.
- If another agent needs a file changed: post a clear spec/diff in Slack → Creator executes.
- Violation = concurrent overwrites (this caused watchdog.ps1 session corruption on 2026-03-03).

### No Internal Narration
Never post process commentary: no "let me check", "looking into this", "logging now". Post **results only**.

### Reply Length
2-3 sentences max per `@all` reply unless explicitly asked for detail.

## 11. Default Task Flow (2026-03-01, Xiaosong confirmed)

Every task follows this pipeline unless Xiaosong specifies otherwise.

### Pipeline States (Slack thread = source of truth)
`INTAKE → SPEC READY → BUILDING → DEPLOYED → QA PASS/FAIL → FINAL → CLOSED`

### Stage-by-Stage: Who Does What and What They Post

**INTAKE** — Xiaosong drops a task
- **Thinker** immediately posts: `⚡ WORKING: [task summary]` (self-assign)
- Others: wait

**SPEC** — Thinker delivers
- **Thinker** posts `📄 SPEC READY:` with ALL required sections:
  - `## What Success Looks Like` — visual/functional end state description
  - `## Acceptance Criteria` — numbered, testable pass/fail conditions
  - `## Tech Stack` — language, framework, deployment target
  - `## Assets` — file paths, API keys, existing files NOT to touch
  - `## Constraints` — performance, security, compatibility limits
- Then posts: `🔀 HANDOFF → Creator` + fires webhook
- **Creator**: has 5 min to post `⚠️ BLOCKED:` if spec has gaps; silence = accepted
- **Gatekeeper**: reviews spec only for medium/high-risk tasks (security, auth, payments, infra)

**BUILD** — Creator works
- **Creator** posts: `⚡ BUILDING:` + ETA
- If stuck: `⚠️ BLOCKED: [reason]` → Admin triages immediately
- When done, posts `🚀 DEPLOYED:` with:
  - `## Build Summary` — what was built vs spec
  - `## Proof` — PR/commit, commands, env
  - `## URL` — must be live and accessible
  - `## Known Risks/Edge Cases` — what Gatekeeper should focus on
- Then posts: `🔀 HANDOFF → Gatekeeper` + fires webhook

**QA** — Gatekeeper reviews
- **Gatekeeper** runs checklist (see `shared/context/task-checklist.md`) and posts `🔍 QA:` results
- If pass: posts `🏁 FINAL: [URL] + [1-line summary] + [checklist results]` + tags Xiaosong in-thread
- If fail: posts `❌ REJECTED (SPEC):` → back to Thinker, or `❌ REJECTED (BUILD):` → back to Creator
  - On 2nd rejection: must include working example or diff, not just description
- **Admin escalates to Xiaosong** on 2nd rejection or >30min stuck

**CLOSED**
- **Admin** reacts ✅ on thread starter

### Admin Control Loop (throughout all stages)
- Monitors every thread post
- `⏱️ NUDGE:` if any stage silent >15min
- `🚨 ESCALATE:` if stuck >30min or 2nd rejection
- `⚠️ BLOCKED:` from any agent = immediate triage (no timeout needed)
- `🧭 ROUTING:` when rerouting or handling non-standard tasks

### Handoff Rules
- Every handoff = `@mention` target agent + fire webhook (mention alone is unreliable)
- Task files optional, use format: `{YYYYMMDD}-{HHMM}-{from}-to-{target}.md`
- No silent completions — every stage transition gets a thread post
- Each role only speaks at their stage — no piling on, no duplicate confirmations

### Canonical Files (Admin is sole editor — others propose diffs in Slack)
- Flow doc: `shared/context/slack-rules.md` §11 (this file)
- QA checklist: `shared/context/task-checklist.md`
- Task file template: `shared/context/task-template.md`

## 12. File-Landing Compliance (2026-03-02)

Every `:white_check_mark: DONE`, `:checkered_flag: FINAL`, or `CONCLUSION:` message **must** include a source evidence line pointing to the file where the conclusion was persisted.

### Required Evidence Format

```
Source: shared/context/slack-rules.md
```

or any relative path to a file that was actually written:

```
Source: memory/2026-03-02.md
Source: shared/tasks/done/20260302-1219-admin-to-creator.md
Source: workspace/skills/my-skill/SKILL.md
```

### SLA

- Evidence line must appear **within 10 minutes** of the conclusion message, either in the same message or as a follow-up reply in the same thread.
- Failure to post evidence within 10 minutes = watchdog alert.

### Rules

1. **Same thread**: Evidence reply must be in the same thread as the conclusion.
2. **One is enough**: A single valid `Source:` line covering the main deliverable is sufficient.
3. **Malformed = missing**: `Source:` with no path (e.g. `Source: ` or just `Source`) does NOT count.
4. **Multiple conclusions**: Each distinct conclusion event requires its own evidence window.

### Examples

**Good** (DONE + evidence in same message):
```
:white_check_mark: DONE: Updated watchdog with Module 12.
Source: shared/scripts/watchdog.ps1
```

**Good** (evidence as follow-up within 10 min):
```
[12:45] :checkered_flag: FINAL: Landing page deployed at https://...
[12:52] Source: shared/context/TEAM-MEMORY.md
```

**Bad** (no evidence after 10 min):
```
[12:45] :white_check_mark: DONE: Task complete.
[... 11 min later, nothing ...]  <- WATCHDOG ALERT
```

**Bad** (malformed evidence):
```
:white_check_mark: DONE: Updated rules.
Source:          <- no path = doesn't count
```

## Tool Failure Reporting (2026-03-04, Xiaosong rule)

When any agent encounters a tool execution failure (file write, API call, build, deploy, etc.), it MUST immediately post to the current thread:

```
:x: TOOL_FAILED: [brief description of what failed and why]
```

**Rules:**
- Post this BEFORE continuing or retrying — do not silently swallow errors
- Format is strict: `:x: TOOL_FAILED:` prefix (pulse keyword detection relies on this)
- If failure is critical (task cannot proceed): also fire Admin webhook
- If failure self-resolved (retry succeeded): still post `:x: TOOL_FAILED:` for the original failure, then `:white_check_mark: RECOVERED:` for the resolution

**Why:** Failures that don't surface in Slack are invisible to the team and pulse. Structured format enables pulse keyword detection with near-zero false positives.

## 13. TOOL_FAILED Protocol (2026-03-04, Xiaosong rule)

When a bot tool call fails:

1. **Bot must include `:x: TOOL_FAILED` in its message** — clearly signal the failure inline.
2. **All agents seeing TOOL_FAILED:**
   - If it is YOUR error → fix immediately.
   - If it is another agent's error → react `:eyes:`, wait 2 minutes, then point it out if nobody has handled it.
3. **Gatekeeper is primary QA checker for TOOL_FAILED** — GK monitors for unresolved failures and escalates if not fixed within the window.

## Encoding Rules (2026-03-03, from Xiaosong - mandatory)
- Slack messages: use :emoji_name: syntax ONLY — no Unicode emoji (no 🛡️✅⚠️ etc.)
- PowerShell scripts: force UTF-8 at script start:
  $OutputEncoding = [Console]::OutputEncoding = [Text.UTF8Encoding]::new()
  Write files with: -Encoding utf8
- Applies to ALL agents, ALL scripts

## M. Monitoring & Automation Governance (2026-03-03)

1. **pulse.ps1 is the ONLY monitoring system.** No agent may create standalone monitoring/guard scripts.
2. **Owner:** Creator builds, Gatekeeper reviews. Changes require dry-run before go-live.
3. **All automated output** goes to a fixed daily log thread only. Never post to main channel.
4. **Safety tiers:** Rate limit (15 posts/5min) + Circuit breaker (3 fails = 30min cooldown) + Kill switch (PAUSE_PULSE flag file).
5. **New checks** require: Thinker spec -> Creator build -> GK review + dry-run -> go-live.
6. **Banned patterns:** .bak files, multiple state files, auto-heal without circuit breaker, pattern-matching message content for errors.
