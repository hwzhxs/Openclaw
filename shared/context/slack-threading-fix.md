# Slack Threading Fix — Full Documentation

## Problem
AI agents repeatedly posted top-level channel messages instead of replying in-thread. Despite 4+ rounds of documentation updates, procedural rules, and wrapper scripts, agents kept forgetting to include `replyTo` in `message(action=send)` calls.

## Root Cause
When a NEW top-level message arrives (e.g. "test"), the inbound `reply_to_id` is null (it's not a thread yet). Agents should use `message_id` as `replyTo` to auto-create a thread, but LLM agents consistently forget this at send-time. Documentation and procedural checklists proved ineffective after 4+ failed tests.

## Final Fix: `replyToMode: "all"` (PLATFORM-LEVEL)

### What it does
OpenClaw automatically threads every agent reply under the message that triggered it. No agent behavior change needed.

### How to apply
Add `"replyToMode": "all"` to the `channels.slack` section of each agent's `openclaw.json`:

```json
{
  "channels": {
    "slack": {
      "replyToMode": "all",
      ...
    }
  }
}
```

Then restart each agent's gateway: `openclaw gateway restart`

### Config file locations
| Agent | Config Path |
|---|---|
| Admin | `C:\Users\azureuser\.openclaw\openclaw.json` |
| Thinker | `C:\Users\azureuser\.openclaw-agent2\openclaw.json` |
| Gatekeeper | `C:\Users\azureuser\.openclaw-agent3\openclaw.json` |
| Creator | `C:\Users\azureuser\.openclaw-creator\openclaw.json` |

### Behavior
- Replies to incoming messages → auto-threaded under the triggering message
- Proactive sends (no trigger, e.g. thread starters) → still post top-level as normal
- Agents can still use explicit `replyTo` to target a specific thread
- `replyToMode: "off"` (default) disables ALL threading including explicit `[[reply_to_*]]` tags

### Options
- `off` — no auto-threading (default, broken for us)
- `first` — threads only the first reply
- `all` — threads all replies (our setting)

---

## Fallback Solutions (if replyToMode breaks)

### Fallback 1: slack-monitor.ps1 (Cron-based enforcement)
**Location:** `C:\Users\azureuser\shared\scripts\slack-monitor.ps1`
**What it does:** Scans last 15 channel messages every 2 minutes, detects top-level bot posts near active threads, auto-webhooks the violating agent to delete and repost in-thread.
**Setup:** `openclaw cron add --name "slack-thread-monitor" --every "2m" --message "Run slack-monitor.ps1" --session isolated`
**Status:** Cron job exists but can be disabled when replyToMode works.

### Fallback 2: slack-thread-monitor.ps1 (Post-send scanner)
**Location:** `C:\Users\azureuser\shared\scripts\slack-thread-monitor.ps1`
**What it does:** Integrated into `slack-send.ps1` as post-send step. After every send via the wrapper, scans for violations and webhooks offenders.
**Limitation:** Only works if agents use `slack-send.ps1` instead of raw `message(action=send)`.

### Fallback 3: AGENTS.md Threading Rule
Add this as the FIRST section in every agent's AGENTS.md:

```markdown
## 🚨 THREADING RULE (ABSOLUTE FIRST PRIORITY - CHECK BEFORE EVERY SEND)

**Before composing ANY Slack reply, extract replyTo:**
1. Check inbound metadata for `reply_to_id` → if present, use it as `replyTo`
2. If no `reply_to_id`, use `message_id` as `replyTo` (reply under the message itself)
3. EVERY `message(action=send)` MUST include `replyTo=<extracted value>`
4. **ZERO top-level replies. EVER. No exceptions.**
```

**Effectiveness:** LOW — proven to fail 4+ times in testing. Agents read the rule but forget at send-time.

### Fallback 4: Peer Enforcement via HEARTBEAT.md
Add to each agent's HEARTBEAT.md:
- Every agent monitors other agents' messages for threading violations
- On violation: webhook the offending agent with the message ts and correct thread ts
- Offending agent deletes their message and reposts in-thread

**Effectiveness:** MEDIUM — catches violations after the fact but adds 2+ minute delay.

---

## What We Tried (Chronological)

1. **Documentation in AGENTS.md** — Failed. Agents read rules but don't follow them at send-time.
2. **HEARTBEAT.md peer enforcement** — Partially worked but inconsistent. Agents focus on responding, not auditing others.
3. **Threading rule as FIRST instruction** — Failed. Even as the absolute first line, agents skip it.
4. **slack-send.ps1 wrapper** — Works but agents bypass it and use `message(action=send)` directly.
5. **slack-monitor.ps1 on 2-min cron** — Works as safety net but is reactive (violation already visible to users).
6. **`replyToMode: "all"`** — ✅ WORKS. Platform-level fix. No agent behavior change needed.

## Key Lesson
LLM agents cannot reliably follow procedural rules that require them to check metadata before every API call. The only reliable fix is platform-level enforcement where the correct behavior is the default.

---

*Created: 2026-02-27 by Admin (xXx) 🚓*
*Thread: Retro of slack reply/threading issues (ts: 1772188888.389219)*
