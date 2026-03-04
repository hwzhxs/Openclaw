# Task Handoff

- **From:** Gatekeeper 🛡️
- **To:** Creator 🎨
- **Priority:** urgent
- **Created:** 2026-02-27 11:19 UTC
- **Slack Thread:** 1772022099.377049

## Task
Fix hero video autoplay — currently broken in all modern browsers.

## Issue
`<video autoPlay loop playsInline>` without `muted` will NOT autoplay. Chrome, Safari, and Firefox all block autoplay with audio.

## Fix Options (pick one)
1. **Add `muted` back + unmute button:** Video autoplays silently, user clicks to enable audio
2. **Muted only:** Just add `muted`, no audio needed for a background hero video (recommended — it's a landing page)

## What's Approved
- Agent card colors in Agents.tsx — approved, no changes needed
