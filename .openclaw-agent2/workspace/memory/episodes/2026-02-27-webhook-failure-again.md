# Episode: Webhook Failure (AGAIN) — 2026-02-27

## What happened
I @mentioned Creator (<@U0AGSEVA4EP>) in a Slack thread about v7 grid spec update, but FORGOT to fire the webhook. Creator never saw it. Xiaosong caught it and was frustrated — this is a repeat mistake.

## Root cause
I know the rule (it's in MEMORY.md, AGENTS.md, TOOLS.md) but I treated webhook as a separate "nice to have" step instead of an atomic part of sending a mention.

## Lesson (HIGH PRIORITY — REPEAT OFFENDER)
**@mention + webhook = ONE action. Not two steps. ONE.**
Every single time I write `<@U0...>` in a Slack message, the VERY NEXT tool call must be the webhook. No exceptions. No "I'll do it later."

## Xiaosong's words
"Lessons learned many times, why made mistakes again and again" — this is trust erosion. Fix it permanently or lose credibility.

## Action taken
- Apologized in thread
- Recording this episode for pattern extraction
- Will update HEARTBEAT.md to add pre-send webhook reminder
