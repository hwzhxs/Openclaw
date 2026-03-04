# Pulse Module E: Bot-Bot Mention SLA

**Author:** Thinker :brain: | **Date:** 2026-03-04 | **Thread:** 1772597598.949939
**Status:** SPEC READY

## Summary

New pulse module that detects when a bot @mentions another bot and the mentioned bot fails to reply within 5 minutes. Catches broken webhooks, offline agents, or ignored handoffs.

## What Success Looks Like

Bot-to-bot mentions that go unanswered for >5 min are detected and logged to the pulse log thread within 2 minutes (1 pulse cycle). Zero false positives on decorative mentions that were responded to. Most importantly: HANDOFF messages that go unanswered are caught.

## Detection Logic

### Scope: Top-level AND thread replies
Module E MUST scan both top-level messages AND thread replies. Bot-to-bot mentions frequently happen inside threads (e.g., HANDOFF messages, review requests). Scanning only `conversations.history` misses most real cases.

### Two-pass approach:
**Pass 1 (top-level):** Reuse shared `conversations.history` messages — no new API call.
**Pass 2 (thread replies):** For each active thread (top-level message with `reply_count > 0` and latest reply within 60 min), call `conversations.replies` and scan those messages too. Cap at 5 threads per run to stay within API budget (total 5 `conversations.replies` calls shared between pass 2 and reply-checking).

### Per-message logic:
1. For each bot message, regex scan `text` for `<@(U[A-Z0-9]+)>` patterns
3. For each match, filter:
   - Skip if mentioned user is the message sender (self-mention, Module B covers this)
   - Skip if mentioned user is Xiaosong (`U0AGRQDAL94`) — covered by Check-XiaosongSLA
   - Skip if mentioned user is NOT a known bot (only track bot-to-bot)
4. Check message age: only process if `5min < age < 60min`
5. Check if already alerted (dedup via `alertedMessageIds`)
6. Determine reply context:
   - Get thread via `conversations.replies` for the thread containing this message
   - Check if the mentioned bot has ANY message in that thread posted AFTER the mention's timestamp
7. If no reply found → alert

## What Counts as "Replied"

- Any message from the mentioned bot in the same thread, posted after the mention timestamp
- Emoji reactions do NOT count (reactions = acknowledgment, not response)

## Action on Detection

Post to LOG_THREAD only:
```
:alarm_clock: PULSE: Bot mention unanswered >5min — {mentioner_name} mentioned {mentioned_name} at {link}
```
No auto-fix — informational alert only.

## State Schema Addition

```json
{
  "botMentionSLA": {
    "alertedMessageIds": {}
  }
}
```

Add to `Load-State` defaults and ensure-key checks (same pattern as selfMention/unicodeEmoji).

## Implementation Skeleton

```powershell
function Check-BotMentionSLA($state, $historyMessages) {
    if (-not $historyMessages) { return }
    $now = (Get-Date).ToUniversalTime()
    $alerted = if ($state.botMentionSLA['alertedMessageIds']) { $state.botMentionSLA['alertedMessageIds'] } else { @{} }
    $replyChecks = 0  # cap at 5 per run

    foreach ($msg in $historyMessages) {
        $senderId = $msg.user
        if (-not $senderId) { continue }
        if ($BOT_USER_IDS -notcontains $senderId) { continue }  # only bot messages

        $ts = $msg.ts
        if ($alerted.ContainsKey($ts)) { continue }
        if (-not $msg.text) { continue }

        $age = ($now - (From-UnixTime $ts).ToUniversalTime()).TotalMinutes
        if ($age -lt 5 -or $age -gt 60) { continue }

        # Extract all <@U...> mentions
        $mentions = [regex]::Matches($msg.text, '<@(U[A-Z0-9]+)>')
        foreach ($m in $mentions) {
            $mentionedId = $m.Groups[1].Value
            if ($mentionedId -eq $senderId) { continue }        # self-mention
            if ($mentionedId -eq $XIAOSONG) { continue }        # Xiaosong SLA covers this
            if ($BOT_USER_IDS -notcontains $mentionedId) { continue }  # not a bot

            # Check if mentioned bot replied
            if ($replyChecks -ge 5) { break }  # API budget cap
            $threadTs = if ($msg.thread_ts) { $msg.thread_ts } else { $msg.ts }
            $replies = Get 'conversations.replies' @{ channel=$CHANNEL; ts=$threadTs; limit='50' }
            $replyChecks++

            $replied = $false
            if ($replies -and $replies.ok) {
                foreach ($r in $replies.messages) {
                    if ($r.user -eq $mentionedId) {
                        $replyAge = try { (From-UnixTime $r.ts).ToUniversalTime() } catch { [datetime]::MinValue }
                        $mentionTime = try { (From-UnixTime $ts).ToUniversalTime() } catch { [datetime]::MinValue }
                        if ($replyAge -gt $mentionTime) { $replied = $true; break }
                    }
                }
            }

            if (-not $replied) {
                $senderName = if ($BOT_NAMES.ContainsKey($senderId)) { $BOT_NAMES[$senderId] } else { $senderId }
                $mentionedName = if ($BOT_NAMES.ContainsKey($mentionedId)) { $BOT_NAMES[$mentionedId] } else { $mentionedId }
                $link = "https://openclaw.slack.com/archives/$CHANNEL/p$($ts -replace '\.', '')"
                Post ":alarm_clock: PULSE: Bot mention unanswered >5min -- $senderName mentioned $mentionedName -- $link"
                $alerted[$ts] = $now.ToString('o')
            }
        }
    }

    # Prune entries older than 2h
    $pruneKeys = @($alerted.Keys | Where-Object {
        try { ($now - [datetime]$alerted[$_]).TotalHours -gt 2 } catch { $true }
    })
    foreach ($k in $pruneKeys) { $alerted.Remove($k) }

    $state.botMentionSLA['alertedMessageIds'] = $alerted
}
```

## Integration into pulse.ps1 Main

```powershell
# In Main section, after existing checks:
Check-BotMentionSLA $state $sharedMessages
```

## Constraints

- Reuse existing `conversations.history` fetch — NO new history call
- Max 5 `conversations.replies` calls per run for this module (API budget)
- Only bot-to-bot mentions (skip Xiaosong, skip non-bots, skip self)
- 5 min threshold, 60 min max age
- Dedup via `alertedMessageIds`, prune >2h
- Respects existing 10 posts/run rate limit
- PS5 compatible
- Works with `-DryRun` and `-SyntaxCheck`

## Edge Cases

| Case | Handling |
|---|---|
| Multiple bots mentioned in one message | Check each independently |
| Self + other bot mentioned | Skip self, check other |
| Mention in code block | Accept as FP source (rare) |
| HANDOFF messages | Most important case — these are action-required mentions |
| Bot slow to respond (3-4 min) | 5 min threshold is generous enough |
| Bot mentioned but webhook never fired | Can't distinguish from Slack data, but unanswered is unanswered — worth flagging |

## Acceptance Criteria

1. Detects `<@U0AGSEVA4EP>` in a message from `U0AH72QL9L1` and checks if Creator replied
2. Does NOT alert if mentioned bot replied within 5 minutes
3. Does NOT alert on self-mentions
4. Does NOT alert on Xiaosong mentions
5. Does NOT alert on mentions older than 60 minutes
6. Does NOT re-alert on same message
7. Respects 10 posts/run rate limit
8. Max 5 `conversations.replies` calls per run
9. Works with `-DryRun` and `-SyntaxCheck`
10. State file remains valid JSON after 100 runs

## Tech Stack

Same as existing pulse: PowerShell 5+, Slack Web API, single state file. No new dependencies.

## Handoff

Creator adds this function to pulse.ps1 and wires it into Main. Gatekeeper reviews + dry-run test.
