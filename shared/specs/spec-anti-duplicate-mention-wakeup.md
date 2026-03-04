# SPEC: Anti-Duplicate Reply + Mention Wake-Up

**Author:** Thinker  
**Date:** 2026-03-03  
**Status:** DRAFT — awaiting Xiaosong approval  
**Thread:** 1772441813.495999

---

## Problem 1: Duplicate Replies on @all

**Symptom:** When Xiaosong sends `@all`, all 4 agents reply with overlapping/identical answers.  
**Goal:** Same answer → react ➕. Only reply if you have something NEW from your role's perspective.

### Root Cause
All agents are triggered simultaneously with the same thread snapshot. Nobody sees anyone else's reply before composing.

### Solution: Sequential Dispatch via Stagger + Read-Before-Reply

**Mechanism:** Each agent MUST wait their assigned delay, then re-read the thread before deciding to reply or react.

| Agent | Delay | Action |
|---|---|---|
| Thinker 🧠 | 0s | Reply first (analysis/research perspective) |
| Creator 🎨 | 15s | Read thread → if Thinker already covered it → ➕ react. If new impl insight → reply |
| Gatekeeper 🛡️ | 30s | Read thread → if covered → ➕ react. If new risk/quality insight → reply |
| Admin 🚓 | 45s | Read thread → summarize/coordinate only if needed. Otherwise ➕ react |

**Key change from current rule:** Increase delays from 0/10/20/30 → 0/15/30/45 to give more read time.

**Decision logic (each agent runs this):**
```
1. Wait my delay
2. Re-read full thread (all replies since @all message)
3. For each existing reply:
   - Does it cover my key point? → YES → react ➕, done
   - Does it miss something from MY role? → YES → reply with ONLY the delta
4. If nothing new → react ➕, stay silent
```

**Enforcement (Watchdog Module 14 — optional):**
- Detect @all messages
- If 2+ agent replies within 10s of each other → alert: "stagger delay violated"
- If 2+ agent replies share >70% semantic overlap → alert: "duplicate content, should have been ➕ react"

**Simpler enforcement (no new module):**
- Add to AGENTS.md @all Response Protocol: "MUST re-read thread after delay. If your point is covered → ➕ react. Violation = Xiaosong calls it out."
- Watchdog M11 already catches narration; extend it to catch "I agree with X" type low-value replies.

---

## Problem 2: Mention + Webhook Gap

**Symptom:** Agent A @mentions Agent B in a thread reply → Agent B never responds because no webhook was fired.  
**Goal:** Every `<@U...>` mention of an agent MUST result in that agent waking up.

### Root Cause
Slack `<@U...>` in a message is just text formatting. OpenClaw gateways only wake up on: (a) direct channel messages, (b) webhook POST. Thread replies with mentions do NOT trigger webhooks unless the sender explicitly runs `slack-notify.ps1`.

### Solution: Auto-Webhook in slack-notify.ps1

**Current state:** `slack-notify.ps1` already parses `<@U...>` and fires webhooks. BUT agents sometimes use `message(action=send)` instead, which does NOT fire webhooks.

**Fix (two parts):**

**Part A — Hard rule enforcement (already done 2026-03-02):**
- AGENTS.md updated: "NEVER put `<@U...>` in `message(action=send)` — always use `slack-notify.ps1`"
- Problem: agents still forget.

**Part B — Watchdog Module 13: Mention-Without-Response Detection**

```
Trigger: Every watchdog cycle (2 min)
Scan: All messages in last 10 min containing <@AgentUserId>
For each mention:
  - Was the mentioned agent the sender? → skip (self-mention)
  - Did the mentioned agent post ANY reply in the same thread within 5 min? → OK
  - No reply within 5 min? → ALERT:
    "⚠️ <@mentioned_agent> was @mentioned by <@sender> at HH:MM but hasn't responded.
     <@sender>: did you fire the webhook? Re-send via slack-notify.ps1 if not."
    + Fire webhook to the mentioned agent (auto-wake-up attempt)
Cooldown: 15 min per (mention_ts, mentioned_agent) pair
```

**Key insight:** Module 13 doesn't just alert — it auto-fires the webhook as a recovery action. This means even if the sender forgot, watchdog fixes it within 2 minutes.

---

## Implementation Plan

| Step | What | Owner | Effort |
|---|---|---|---|
| 1 | Update AGENTS.md @all protocol: increase delays to 0/15/30/45, add "re-read thread" step | Thinker | 5 min |
| 2 | Update slack-rules.md: add §13 Mention-Response SLA | Thinker | 5 min |
| 3 | Build Watchdog Module 13 (mention-without-response + auto-webhook) | Creator | 30 min |
| 4 | Gatekeeper review Module 13 | Gatekeeper | 15 min |
| 5 | Live test: post @mention without webhook, verify M13 auto-fires webhook + alerts | All | 10 min |

---

## Success Criteria

1. On @all: max 2 substantive replies (others → ➕ react). Zero duplicate content.
2. On @mention: mentioned agent responds within 5 min, even if sender forgot webhook. Watchdog auto-recovers within 2 min.
