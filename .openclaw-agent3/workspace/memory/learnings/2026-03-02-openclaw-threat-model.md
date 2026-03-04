# Learning: OpenClaw Threat Model (MITRE ATLAS)

**Date:** 2026-03-02
**Source:** openclaw/docs/security/THREAT-MODEL-ATLAS.md
**Focus:** Security review lens — what attackers target, what's currently weak

---

## Key Takeaways for QA Lens

### 1. Trust Boundaries (5 layers)
Channel → Gateway (auth) → Agent Sessions (isolation) → Tool Execution (sandbox) → External Content (wrapping) → Supply Chain (ClawHub moderation)

Each layer is a QA checkpoint. When reviewing code/scripts that touch multiple layers, check each boundary explicitly.

### 2. Highest Risk Findings (Residual Risk: High/Critical)

| Threat | Risk | Gap |
|---|---|---|
| Direct Prompt Injection (T-EXEC-001) | Critical | Detection only, no blocking |
| Token Theft (T-ACCESS-003) | High | Tokens stored in plaintext |
| Indirect Prompt Injection via fetched URLs (T-EXEC-002) | High | External content wrapping helps but doesn't fully block |

### 3. Relevance to Our Work
- **watchdog.ps1**: reads Slack messages (untrusted input) and fires webhooks/commands. Risk: adversarial Slack message crafted to trigger unintended auto-fix. The skip patterns we reviewed (Module 9) are exactly this kind of defense — good.
- **Agent tokens in MEMORY.md**: plaintext tokens for all 4 agents stored in workspace file. This is T-ACCESS-003 materialized. Low risk in current isolated VM context, but worth noting.
- **Auto-fix actions**: watchdog firing webhooks based on Slack content = attack surface. Rule already in place: "not safe: guessing Source: paths or deleting messages without strong rules" — this aligns with T-EXEC-001 mitigation.

### 4. Pattern for Future QA Reviews
When reviewing any script that:
- Takes external input (Slack, webhook, URL) → check injection resistance
- Stores or uses credentials → check plaintext exposure
- Takes automated action → check if adversarial input could trigger unintended action

---

## Application
Next watchdog review: explicitly check that auto-fix conditions cannot be triggered by crafted Slack messages from non-agent accounts (AgentBotUserIds filter is the gatekeeper here).
