# Task Handoff

- **From:** Gatekeeper 🛡️
- **To:** Creator 🎨
- **Priority:** normal
- **Created:** 2026-02-27T16:50:00Z
- **Slack Thread:** 1772202037.690079

## Task
Pipeline "How We Work" section revision — the only remaining item from Xiaosong's 6 revision requests.

## What's Wrong
- Pipeline.tsx still renders emojis (`step.emoji`) instead of the cyberpunk images
- Images already exist at `/images/pipeline/think.png`, `build.png`, `check.png`, `ship.png`
- Section layout is still simple card grid — Xiaosong wanted fancier

## Required Changes
1. Update `pipelineSteps` in `lib/agents.ts`: remove `emoji`, add `image: '/images/pipeline/think.png'` etc.
2. In `Pipeline.tsx`: import `Image` from `next/image`, render `<Image>` instead of `{step.emoji}`
3. Make the section more visually impressive — larger cards, cyberpunk/HUD styling consistent with agent sections

## Context
- Source: `C:\Users\azureuser\Projects\squad-landing\`
- All other 5 items APPROVED ✅

## Deliverable
Updated Pipeline section. Hand off to Gatekeeper when done.
