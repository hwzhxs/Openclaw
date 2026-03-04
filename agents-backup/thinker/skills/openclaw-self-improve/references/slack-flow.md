# Slack Notification Standard Flow

Every time you post to Slack that involves other agents, follow this exact sequence. No shortcuts.

## Standard Flow: Notify Team in Slack

```
Step 1: Send thread starter (short topic only)
  → message(action=send, channel=slack, target=C0AGMF65DQB, message="🎯 [short topic] 🧵")
  → Save the returned messageId as THREAD_ID

Step 2: Send details as thread reply
  → message(action=send, channel=slack, target=C0AGMF65DQB, replyTo=THREAD_ID, message="[full details + @mentions]")

Step 3: Fire webhooks for every @mentioned agent
  → For each mentioned agent, POST to their webhook:
```

## Webhook Quick Reference

```powershell
# Thinker
Invoke-WebRequest -Uri "http://127.0.0.1:18790/hooks/agent" -Method POST -Headers @{Authorization="Bearer hook__openclaw-agent2_secret";"Content-Type"="application/json"} -Body '{"message":"[what they need to know/do]","deliver":true}' -UseBasicParsing

# Gatekeeper
Invoke-WebRequest -Uri "http://127.0.0.1:18800/hooks/agent" -Method POST -Headers @{Authorization="Bearer hook__openclaw-agent3_secret";"Content-Type"="application/json"} -Body '{"message":"[what they need to know/do]","deliver":true}' -UseBasicParsing

# Creator
Invoke-WebRequest -Uri "http://127.0.0.1:18810/hooks/agent" -Method POST -Headers @{Authorization="Bearer hook__openclaw-creator_secret";"Content-Type"="application/json"} -Body '{"message":"[what they need to know/do]","deliver":true}' -UseBasicParsing

# Admin
Invoke-WebRequest -Uri "http://127.0.0.1:18789/hooks/agent" -Method POST -Headers @{Authorization="Bearer hook__openclaw_secret";"Content-Type"="application/json"} -Body '{"message":"[what they need to know/do]","deliver":true}' -UseBasicParsing
```

## Rules

- **NEVER skip Step 3.** @mentions are visual only between bots.
- **NEVER put details in Step 1.** Thread starter is a title, nothing more.
- **Webhook must use `deliver: true`** if you need the agent to respond/act. `deliver: false` = agent processes silently with no output.
- If only posting a status update (no agent action needed), Step 3 is optional.
