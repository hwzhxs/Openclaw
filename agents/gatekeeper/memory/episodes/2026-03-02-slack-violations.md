# Episode: Team Collaboration Flow Locked + Self-Violations

**Date:** 2026-03-02
**Type:** learning + mistake
**Severity:** medium (self-violation caught by Xiaosong)

## What Happened

Long thread on collaboration flow design. All 4 agents participated and locked:
- Default task pipeline (Thinker → Creator → Gatekeeper → Xiaosong, Admin monitors)
- Per-role message templates with required sections
- Canonical files: slack-rules.md §11, task-checklist.md, task-template.md
- Single-editor rule (Admin owns canonical files)
- Rejection flow with SPEC/BUILD labels
- BLOCKED signal for immediate Admin triage

## My Violations

1. **Posted "react" as text message** instead of actually using the emoji reaction API — twice. Had to delete both posts.
2. During dry-run, I posted `🛡️ Standing by for Stage 5-6. Waiting on Creator's DEPLOYED post to begin QA.` — this is internal narration / status update, lower-value but acceptable since it signals I'm ready.

The "react" text messages were pure mistakes — the `message(action=send)` tool sent the literal word "react" because I narrated the action instead of executing it.

## Root Cause

I used `slack-notify.ps1` to "react" but the script doesn't support emoji reactions — it only sends text. I should have used the Slack API directly.

## Fix Applied

- Created `C:\Users\azureuser\shared\scripts\react.ps1` for proper emoji reactions
- Deleted both bad "react" text messages
- Added emoji reaction to Xiaosong's message properly

## Lesson

**Never narrate an action. Execute it or stay silent.**
For emoji reactions: use `react.ps1`, not `slack-notify.ps1` and not `message` tool.

```powershell
# Correct usage:
powershell -File "C:\Users\azureuser\shared\scripts\react.ps1" -Token "<bot_token>" -Channel "<channel_id>" -Timestamp "<message_ts>" -Emoji "<emoji_name>"
```

## Pattern Match

This is the same pattern as Thinker's violation: posting reasoning about what you're doing instead of just doing it (or not). "No internal narration" means no action narration either.
