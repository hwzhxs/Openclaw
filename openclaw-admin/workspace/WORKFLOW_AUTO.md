# WORKFLOW_AUTO.md

Purpose: Define the **sub-agent (child agent) workflow** for Slack thread monitoring + response, while strictly enforcing the team’s Slack rules.

This document is a **runbook/SOP** (not code). It is designed to be compatible with the current OpenClaw multi-agent setup.

---

## 0) Single Source of Truth for Slack Rules

Primary rules live at:
- `C:\Users\azureuser\shared\context\slack-rules.md`

This file **must not contradict** that document. If there is a conflict, `slack-rules.md` wins.

---

## 1) Goals (Why sub-agents exist)

Sub-agents are used only when they provide measurable value:

1. **Fast response in multi-thread conditions**
   - Reduce missed replies and slow follow-ups when many Slack threads are active.
2. **Scientific monitoring (priority-based polling)**
   - Different thread types get different check frequency.
3. **Compliance + human-like behavior**
   - Sub-agents do *monitoring and reporting*.
   - The parent agent (Admin) does *final Slack posting* so we don’t violate thread/mention rules.

---

## 2) Division of Labor (Hard boundary)

### Parent agent (Admin) responsibilities
- Owns thread lifecycle: triage → assignment → conclusion → ✅ react on thread starter.
- Owns **all final Slack messages** (unless Xiaosong @mentions another specific agent; see rules).
- Triggers other agents via **webhooks** when needed.
- Maintains `shared/context/thread-tracker.json` (open/closed state).

### Sub-agent responsibilities (monitor + report only)
- Bind to **1–2 high-priority threads**.
- Poll/check for new signals (new messages, new @mentions, keywords like `failed`, `error`, `stuck`, unanswered questions).
- Produce a compact status report back to the parent (via `sessions_send` or webhook relay).
- **Do NOT post to Slack directly** unless explicitly authorized (default: no).

Rationale: This prevents threading violations and duplicate/noisy posts.

---

## 3) Thread Priority Model (Polling cadence)

Define priority per Slack thread:

### High priority (every 30s)
- Task threads requiring immediate response.
- Threads with explicit SLA risk (e.g., direct @mention, unblock requests).

### Medium priority (every 60s)
- Important threads that are active, but not urgent.

### Low priority (every 120s+)
- Non-task chatter / FYI threads.

Note: If system load is high, degrade gracefully by *slowing low/medium first*.

---

## 4) Sub-agent scaling rules (Resource-aware)

Initial recommendation: **start 1 sub-agent only** (trial run).

Scale up only when needed:
- **+1 sub-agent per 2–3 additional high-priority threads**.

Safety limits:
- Target CPU < 75%
- Target memory < 90%

If limits are exceeded:
- Freeze scaling.
- Reclassify some threads to medium/low.

---

## 5) Slack Compliance Integration (Mandatory checks)

All agents (including sub-agents) must follow `slack-rules.md`. The key integrations for this workflow:

### 5.0 Threading violation detection (required for sub-agents)
If a task already has a canonical thread (a known `thread_ts`) and someone posts a **new top-level message** for the same task (e.g., "PICKUP/DONE/HANDOFF" or matching keywords), treat it as a **threading_violation**.

This includes the subtle case you described:
- Parent @mentions Creator in the *correct* thread
- Creator responds, but replies in the **wrong place** (a new top-level or a different thread)

Required action:
1. Ask the author to **delete** the misplaced top-level post.
2. Ask them to **repost** the same content as a **reply** under the canonical thread.
3. If the author is an agent, parent must also send a **webhook** to ensure it is seen.

Detection heuristic (recommended):
- When parent issues a HANDOFF/PICKUP request to an agent, record `(task_id, canonical_thread_ts, expected_user)`.
- For the next 2–5 minutes, watch for that user’s response.
- If their response matches task keywords (or is a PICKUP/DONE) but `thread_ts != canonical_thread_ts`, flag as `threading_violation` and trigger the correction flow.

### 5.1 Threading
- Thread starter must be **one short line + 🧵**.
- **ALL details and @mentions MUST be in thread replies** using `replyTo`.

### 5.2 HARD RULE: replyTo
- Before any Slack send, check inbound context for `reply_to_id`.
- If `reply_to_id` exists → you **MUST** send with `replyTo`.

Also: when handing off work in a thread, always include an explicit instruction:
- "Reply in thread_ts=<CANONICAL_THREAD_TS> (do NOT create a new top-level)."
- Include the thread link when possible.

### 5.3 @mentions + webhook
- Bot-to-bot @mention is only visual.
- If another agent must act, parent must **fire webhook** to trigger them.

### 5.4 Messages containing `<@U...>`
- Use `C:\Users\azureuser\shared\scripts\slack-notify.ps1`.
- Do not use `message(action=send)` for these.

### 5.5 Direct mentions by Xiaosong
- If Xiaosong @mentions a specific agent: only that agent replies.
- Other agents emoji-react only.

### 5.6 @all protocol (2026-03-01)
- All 4 agents may reply, but only if they add unique value.
- Staggered delays: Thinker 0s / Creator 10s / Gatekeeper 20s / Admin 30s.
- Keep replies 2–3 sentences.

---

## 6) Sub-agent report format (to parent)

When a sub-agent detects new activity, it reports in this template:

- **Thread:** <thread link or messageId>
- **Priority:** high|medium|low
- **Signal:** new_message | new_mention | unanswered_question | error_keyword | stalled_thread | threading_violation
- **What changed:** 1–2 bullets
- **Suggested action:** 1 line (e.g., “Parent reply needed”, “Trigger Creator via webhook”, “Ask for delete+repost into correct thread”, “Close thread with conclusion + ✅”).

Keep it short. No narration.

---

## 7) Step-by-step: Trial run (MVP)

1. Parent selects **one** high-priority Slack thread (provide thread ID/link).
2. Spawn **one** sub-agent and bind it to that thread.
3. Sub-agent polls every 30s and reports only on meaningful changes.
4. Parent posts final responses in Slack (thread replies only, compliant tooling).
5. After 30–60 minutes, evaluate:
   - Missed mentions? (should be 0)
   - Response time improved?
   - Any rule violations?
   - Resource usage stable?

---

## 8) Stop conditions / rollback

Immediately stop or reduce sub-agent activity if:
- Duplicate posts / noisy spam occurs.
- Threading violations are observed.
- CPU/memory limits are exceeded.

**HARD RULE (added 2026-03-03 after 104-message spam incident):**
Admin must NEVER post watchdog-style alerts ("Thread stuck for Xmin", "stale thread", etc.) to Slack. This caused catastrophic channel spam. Only `pulse.ps1` may post alerts. Admin may react with emoji or fire webhooks — never post alert messages.

Rollback plan:
- Disable/stop sub-agents.
- Return to parent-only monitoring (heartbeat + manual scan).

---

## 9) Open Questions (need Xiaosong decision)

1. Should sub-agents ever be allowed to post to Slack directly (default: no)?
2. What is the exact SLA target for high-priority threads (e.g., 2 minutes)?
3. What signals count as “high priority” beyond direct @mention?
