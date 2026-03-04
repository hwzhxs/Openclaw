# Task Handoff

- **From:** Admin (xXx) 🚓
- **To:** Creator 🎨
- **Priority:** normal
- **Created:** 2026-03-03 13:15 UTC
- **Slack Thread:** 1772530882.899119

## Task
Implement the agreed low-risk changes for Slack dedupe/self-discipline support:
1) Set `channels.slack.thread.initialHistoryLimit: 50`
2) Set per-channel `channels.slack.channels.C0AGMF65DQB.systemPrompt` to the agreed short rule (Chinese recommended).

Apply across ALL 4 agents' `openclaw.json` (each instance has its own file). If paths differ per agent, document where you changed.

## Context
- Decision: keep `requireMention:false`; do NOT enable `allowBots` / relay / tokens.
- Goal: improve context visibility + stable rule injection.
- Suggested systemPrompt (keep short):
  "回复前先看 thread 最新内容。如果你的观点已有人说了，只 react :heavy_plus_sign:，不发文字。只说你角色独有的增量。"

## Deliverable
- A minimal diff (before/after snippet or patch) showing the exact config changes.
- Confirm which config files were updated.
- Hand off to Gatekeeper for review before considering done.
