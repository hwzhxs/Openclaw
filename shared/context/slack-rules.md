# Slack Rules (Single Source of Truth)

All agents MUST read this before ANY Slack send. No exceptions.

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

- **Slack (including threads): Chinese ONLY**
- **File writes (repo + memory + shared/context): English ONLY** (Chinese can cause encoding corruption across processes)

## 7. Emoji Reactions

- React to messages you've seen/acknowledged
- One reaction per message max
- Use reactions instead of low-value replies ("ok", "got it")

## 7.2 Emoji + Encoding (MANDATORY)

- **When sending via Slack API/scripts, use Slack emoji syntax only** (e.g. `:white_check_mark:`). **Do NOT paste Unicode emoji** (e.g. ✅📤) — they may render as `??`.
- **All PowerShell scripts that send Slack messages MUST use UTF-8 end-to-end**:
  - Console/output encoding forced to UTF-8
  - Any file writes use `-Encoding utf8`
  - HTTP request body sent as UTF-8 bytes (Slack expects UTF-8)

## 7.1 Noise Cleanup SLA (delete fast)

- If you accidentally post low-signal text (e.g., `react`, meta commentary like “emoji only”, internal narration, duplicate stage spam): **delete it within 2 minutes**.
- Admin will prompt deletion as soon as detected; do not wait for Xiaosong to ask.
- If deletion fails: reply with the message timestamp (ts) + error so Admin can debug permissions.

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
- **Creator** (:art:): implementation, how to build it, feasibility
- **Gatekeeper** (:shield:): risks, quality, edge cases, what could go wrong
- **Admin** (:police_car:): coordination, next steps, decisions, summary

### No Internal Narration
Never post process commentary: no "let me check", "looking into this", "logging now". Post **results only**.

### Reply Length
2-3 sentences max per `@all` reply unless explicitly asked for detail.

## 11. Default Task Delivery Pipeline (Spec → Build → QA → FINAL)

This is the default process when Xiaosong drops a task (unless explicitly overridden in-thread).

### 11.1 Source of Truth
- **Slack thread is canonical** for state + artifacts.
- **Task files are optional** (only when work spans sessions / needs persistence). If a task file exists, it must not contradict the thread.

### 11.2 Pipeline States (visible via message prefixes)
1. **INTAKE** (task dropped)
2. **SPEC READY** (Thinker posted spec)
3. **BUILDING** (Creator acknowledged + ETA)
4. **DEPLOYED** (URL + proof posted)
5. **QA PASS / QA FAIL** (Gatekeeper checklist results)
6. **FINAL** (Gatekeeper presents result to Xiaosong in-thread)
7. **CLOSED** (Admin reacts `:white_check_mark:` on thread starter)

### 11.3 Hard Gates (no skipping)
- **No SPEC (with required sections) → Creator does not start.**
- **No DEPLOY proof/URL → Gatekeeper does not start QA.**
- **No QA checklist results → no `:checkered_flag: FINAL:`.**

### 11.4 Role Contract: What Each Role Must Post

#### Admin (monitor + unblock + close)
- Intake reply (1 message): routing + definition of done (DoD) + any SLA notes.
- If stuck: `⏱️ NUDGE:` (15m silence) → `🚨 ESCALATE:` (>30m stuck or 2nd rejection).
- Close: react `:white_check_mark:` on thread starter once FINAL delivered.

#### Thinker (requirements → spec)
Post:
- `⚡ WORKING: [task]` (self-assign) + ETA for spec
- `📄 SPEC READY:` with REQUIRED sections:
  - `## What Success Looks Like`
  - `## Acceptance Criteria` (numbered pass/fail)
  - `## Assets/Links`
  - `## Deploy Target`
  - `## Verification Plan`
Then:
- `🔀 HANDOFF → Creator` (and trigger webhook)

#### Creator (build → deploy)
Post:
- `⚡ BUILDING:` + ETA
- If blocked: `⚠️ BLOCKED:` + what you need (Admin triages immediately)
- `🚀 DEPLOYED:` with REQUIRED sections:
  - `## Build Summary` (what changed vs spec)
  - `## Proof` (PR/commit/commands/env)
  - `## URL` (reachable)
  - `## Known risks/edge cases`
Then:
- `🔀 HANDOFF → Gatekeeper` (and trigger webhook)

#### Gatekeeper (QA → present)
Post:
- `🔍 QA:` checklist results + acceptance-criteria pass/fail matrix
- If fail: `:x: REJECTED (SPEC|BUILD):` exact fix list + owner + re-test steps (and trigger webhook)
- If pass: `:checkered_flag: FINAL:` URL + 1-line summary + what was verified (tag Xiaosong in-thread)

### 11.5 Risk-Based Spec Review (optional)
- For **medium/high-risk** tasks (security/auth/payment/deploy infra): Gatekeeper may do a quick spec sanity check ("buildable + testable?") before Creator starts.
- For routine tasks: skip to keep speed.

### 11.6 Rejection Loop (no stalls)
- `REJECTED (SPEC)` → back to Thinker
- `REJECTED (BUILD)` → back to Creator
- **2nd rejection** OR **>30min stuck** → Admin escalates to Xiaosong with options.

### 11.7 Canonical Checklist Location (no inline duplicates)
- QA checklist lives in: `shared/context/task-checklist.md`
- Only Admin edits canonical files; other agents propose diffs in Slack.
