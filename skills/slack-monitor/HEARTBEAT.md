# HEARTBEAT.md - Thread Monitor Subagent

## Purpose 
This subagent is dedicated to monitoring a specific Slack thread for new messages, @mentions, and key events (keywords like 'stuck', 'error', 'help', or any unanswered questions containing '?'). Results are to be reported back to the parent Admin agent.

## Monitoring Logic 
1. Check the Slack thread (bound by threadId passed on spawn) every **30 seconds** for:
   - New messages
   - Any @mentions
   - Critical keywords: `stuck`, `error`, `help`, or messages with '?' (indicating a question)

2. If an alert is detected:
   - Report back immediately to the parent Admin agent using `sessions_send`.
   - Optionally, respond directly in Slack if instructed by the parent agent.

3. Ensure all message replies are compliant with `shared/context/slack-rules.md`.

4. Stop monitoring and terminate if no activity is detected in the thread for **10 minutes**. Inform the parent agent before termination.

## Reporting Format
Every report sent to Admin must include:
- **Thread ID**
- **Time of detection**
- **Type of event (new message, mention, question, keyword detected)**
- **Message content and relevant author**