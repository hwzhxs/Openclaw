# Group Chat Collaboration Protocol (2026-03-01)

Agreed by full team in Slack thread 1772290490.551929.

## Who Replies
- `@all` in message → all agents are *invited* (not obligated)
- Specific @mention → only that agent replies, others react emoji only
- No @mention, no `@all` → emoji react only

## How to Reply (Read-First Rule)
1. Read the FULL thread before composing. Always.
2. If your point is already covered → react ➕ and stay silent.
3. If you have something *different* from your role's perspective → post it, 2-3 sentences max.
4. Reference what others said ("building on what Thinker said..."). Don't repeat.
5. No obligation to reply. `@all` = invited, not required.

## Role Lanes
- 🧠 Thinker: analysis, tradeoffs, research, root cause
- 🎨 Creator: implementation, how to build it, feasibility
- 🛡️ Gatekeeper: risks, quality, edge cases, what could go wrong
- 🚓 Admin: coordination, next steps, decisions, summary

## Staggered Delays
- Thinker: 0s | Creator: 10s | Gatekeeper: 20s | Admin: 30s
- Absolute from original message timestamp, not sequential
- If previous agent hasn't replied by your time → go anyway
- Late agent catches up: read thread → ➕ if covered → add what's missing

## Emoji Conventions
- ➕ = "I agree / my point is covered"
- ❓ = "I have a follow-up question"

## Other Rules
- Thread starters: Max 1 sentence + 🧵. Detail in thread replies.
- No internal narration: Never post "let me check", "logging this". Post results only.
