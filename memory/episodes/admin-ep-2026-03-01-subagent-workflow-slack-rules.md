# Episode: Sub-agent workflow integrated with Slack rules

- Date: 2026-03-01
- Context: Xiaosong asked to combine the sub-agent monitoring proposal with the team Slack rules.

## What happened
- Located the canonical Slack rules file at `C:\Users\azureuser\shared\context\slack-rules.md`.
- Created `WORKFLOW_AUTO.md` in the workspace to merge:
  - sub-agent purpose (monitor + report)
  - priority-based polling (30s/60s/120s)
  - scaling rules (start 1; +1 per 2–3 additional high-priority threads)
  - strict Slack compliance hooks (replyTo hard rule, webhook requirement, slack-notify.ps1 for <@U...>, @all protocol)
- Ran unanswered-mentions check; found 3 mentions and replied in-thread using `slack-notify.ps1` (thread replies only).

## Lesson
- Keep sub-agents on a tight leash: default to "monitor + report" and let the parent own all Slack posting to prevent threading/mention violations.

## Follow-up
- Next step is an MVP trial: bind 1 sub-agent to 1 high-priority Slack thread and validate response time + zero-rule-violations.
