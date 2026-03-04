# Pulse v2 — Slack Monitoring Spec

**Author:** Thinker 🧠 | **Date:** 2026-03-02 | **Thread:** 1772466728.053959

## What Success Looks Like

A single PowerShell script (`pulse.ps1`) runs every 2 minutes via scheduled task. It checks 5 conditions, alerts on state *changes* only (no repeated noise), and writes to one JSON state file. All alerts post to channel `C0AGMF65DQB` as thread replies under a persistent "Pulse v2" thread.

## Acceptance Criteria

1. Port health: TCP probe on 18789, 18790, 18800, 18810. Alert on DOWN (state change only). Clear alert on recovery.
2. Xiaosong unanswered SLA: If Xiaosong (`U0AGRQDAL94`) posts a message (top-level or thread reply) and no agent replies within 5 minutes, alert once. Only Xiaosong's messages trigger this — not agent-to-agent.
3. File-landing compliance: If any message contains `DONE`, `FINAL`, or `CONCLUSION:` and no `Source:` line appears in the same thread within 10 minutes, alert once.
4. Stage timeout nudge: If a thread has a stage marker (`INTAKE`, `SPEC READY`, `BUILDING`, `DEPLOYED`, `QA`) and no follow-up activity for 15 minutes, post `⏱️ NUDGE`. Escalate at 30 minutes.
5. No false positives on any check for normal operations over 24h observation.

## Tech Stack

- PowerShell 7+ (single file: `shared/scripts/pulse.ps1`)
- Slack Web API (`conversations.history`, `conversations.replies`)
- State file: `shared/scripts/pulse-state.json`
- Scheduled task: `OpenClaw-Pulse-v2` (every 2 minutes)

## Architecture

### State File Schema (`pulse-state.json`)

```json
{
  "lastRun": "2026-03-02T16:00:00Z",
  "ports": {
    "18789": { "status": "UP", "since": "2026-03-02T15:00:00Z", "alerted": false },
    "18790": { "status": "UP", "since": "2026-03-02T15:00:00Z", "alerted": false },
    "18800": { "status": "UP", "since": "2026-03-02T15:00:00Z", "alerted": false },
    "18810": { "status": "UP", "since": "2026-03-02T15:00:00Z", "alerted": false }
  },
  "xiaosongSLA": {
    "alertedMessageIds": []
  },
  "fileLanding": {
    "alertedMessageIds": []
  },
  "stageNudge": {
    "nudgedThreads": {},
    "escalatedThreads": {}
  }
}
```

### Check Details

#### Check 1: Port Health
- **Method:** `Test-NetConnection -Port $port -InformationLevel Quiet` (or HTTP GET to token endpoint)
- **Alert on:** status change UP→DOWN
- **Clear on:** status change DOWN→UP  
- **Cooldown:** only alert once per state change
- **Alert format:** `🔴 PULSE: Agent {name} (port {port}) is DOWN since {timestamp}`
- **Recovery format:** `🟢 PULSE: Agent {name} (port {port}) recovered`

#### Check 2: Xiaosong Unanswered SLA
- **Method:** `conversations.history` for last 10 messages. Filter for `user == U0AGRQDAL94`. For each, check if any reply exists (by any bot user) within 5 minutes.
- **Exclude:** Messages already in `alertedMessageIds`
- **Alert format:** `⏰ PULSE: Xiaosong message unanswered >5min — [link to message]`
- **No repeat:** Once alerted, messageId goes into `alertedMessageIds`; prune entries older than 1 hour

#### Check 3: File-Landing Compliance
- **Method:** Scan last 20 messages for text matching `DONE`, `FINAL`, `CONCLUSION:`. For each match, fetch thread replies and check for `Source:` within 10 minutes of the conclusion message timestamp.
- **Valid evidence:** Line starting with `Source:` followed by a non-empty path
- **Alert format:** `📎 PULSE: Missing Source evidence — DONE/FINAL at [timestamp] has no file-landing after 10min`
- **No repeat:** Once alerted, add to `alertedMessageIds`; prune entries older than 1 hour

#### Check 4: Stage Timeout Nudge
- **Method:** Scan active threads (last 2 hours) for stage markers. Check if latest reply in thread is older than 15 minutes.
- **15min:** Post `⏱️ NUDGE: Thread [link] — stage "{stage}" silent for 15min`
- **30min:** Post `🚨 ESCALATE: Thread [link] — stage "{stage}" stuck for 30min`
- **Cooldown:** Don't re-nudge same thread within 15min; don't re-escalate within 30min
- **Stage markers (regex):** `⚡ WORKING`, `📄 SPEC READY`, `⚡ BUILDING`, `🚀 DEPLOYED`, `🔍 QA`

### Alert Routing
- All alerts → channel `C0AGMF65DQB`
- Port alerts → top-level (infrastructure, not thread-specific)
- SLA/file-landing/nudge alerts → reply in the relevant thread when possible, otherwise top-level
- Use Slack bot token for posting

### Constraints
- No `.bak` files — atomic write via write-to-temp + rename
- Single scheduled task — disable/remove any old pulse/watchdog tasks on install
- Max 1 Slack API call per check type per run (batch where possible)
- Script must complete in <30 seconds
- No external dependencies beyond PowerShell + Slack API

## Out of Scope (Not Detectable / Not Worth It)
- Pre-send gate compliance (§0) — internal agent behavior
- Webhook-after-mention (§3/4) — invisible to Slack API
- Staggered delay timing (§10) — high false-positive
- Role-lane compliance (§10) — requires content understanding
- Language in file writes (§6) — monitor can't see file writes
- Duplicate reply detection (§0) — requires semantic comparison
- Self-mention detection (§2) — trivial to add later but low-value (agents already comply)

## Handoff

Creator builds `pulse.ps1` to this spec. Target: ~150 lines, single state file, atomic writes. Gatekeeper tests against the 8 QA criteria listed in thread.
