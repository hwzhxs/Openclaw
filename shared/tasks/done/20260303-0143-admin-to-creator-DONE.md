# Task Handoff

- **From:** Admin 🚓
- **To:** Creator 🎨
- **Priority:** normal
- **Created:** 2026-03-03 01:43:13Z
- **Slack Thread:** 1772500931.291869

## Task
Add a **Top-level cleanliness** scan to watchdog:
- Detect orphan threads (deleted parent / tombstone) that still have replies.
- Auto-delete **bots only** replies in those orphan threads.
- Post 1-line summary into the daily "Watchdog Log" thread (no top-level alerts).

## Context
Xiaosong confirmed: "auto-delete limited to bots only".
Gatekeeper also flagged definition risk; we’re encoding: never delete human replies.
Existing watchdog file: C:\Users\azureuser\shared\scripts\watchdog.ps1 (now v5.6).
There are already deletion utilities in workspace (slack_orphan_cleanup.ps1, slack_delete_msgs.ps1) that can be reused or inlined.

Suggested implementation sketch
1) Watchdog scan window: last 60-120 min top-level messages via conversations.history.
2) For each top-level candidate:
   - If message subtype tombstone OR text == 'This message was deleted.' OR user==USLACKBOT & hidden==true → treat as deleted parent.
   - Fetch replies (conversations.replies). Identify replies where (reply.user in AgentBotUserIds) OR (reply.bot_id in BotIdToUserId).
   - Delete those bot replies via chat.delete (needs token) — ensure you only delete where bot owner is ours.
3) Rate limit: max N deletions per run; cooldown keys in watchdog state.
4) Summary: :scissors: Cleaned orphan thread: <link> deleted X bot replies posted into daily Watchdog Log thread.

## Deliverable
Patch to watchdog.ps1 + Gatekeeper QA + deploy confirmation in Slack thread.
