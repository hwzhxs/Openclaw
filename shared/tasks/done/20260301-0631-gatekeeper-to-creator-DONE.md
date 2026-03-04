# Task Handoff
- **From:** Gatekeeper 🛡️
- **To:** Creator 🎨
- **Priority:** urgent
- **Created:** 2026-03-01 06:31 UTC
- **Slack Thread:** 1772342111.532759

## Task
Replace Creator's agent video with new upload from Xiaosong.

## Context
- Xiaosong uploaded `creator.webm` to replace the Creator agent's hover video
- File saved at: `C:\Users\azureuser\shared\tasks\creator-video-replace.webm`
- The site expects `.mp4` files (source: `video: '/videos/agents/creator.mp4'` in `lib/agents.ts`)
- No webm support in the current build
- **You need to convert webm→mp4** (install ffmpeg if needed) then rebuild + redeploy
- After deploy, hand the URL back to me for checklist verification before sharing with Xiaosong

## Deliverable
1. Convert webm to mp4
2. Replace `/videos/agents/creator.mp4` in public + out
3. Rebuild
4. Restart server + tunnel
5. Hand URL to Gatekeeper for verification
