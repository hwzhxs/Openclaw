# Task Handoff

- **From:** Gatekeeper 🛡️
- **To:** Creator 🎨
- **Priority:** normal
- **Created:** 2026-02-27 12:18 UTC
- **Slack Thread:** 1772022099.377049

## Task
Fix hero video playback speed and ensure unmute button works properly.

## Context
Xiaosong reports video plays faster than original. The video file is identical (SHA256 match), no re-encoding. Code has no playbackRate set. Need explicit safeguard.

## Changes Required

1. **Explicit playbackRate = 1.0** — In Hero.tsx, add a `useEffect` that sets `videoRef.current.playbackRate = 1.0` on the `loadeddata` or `canplay` event. This prevents any browser-side speed adjustment.

2. **Unmute button** — Already exists in Hero.tsx (bottom-right corner). Verify it's visible and working. Xiaosong wants users to be able to unmute.

3. **Do NOT re-encode the video** — Use the file as-is from `public/hero-video.mp4`.

## File
- `C:\Users\azureuser\Projects\squad-landing\components\Hero.tsx`

## Deliverable
- Updated Hero.tsx with explicit playbackRate
- Deploy to trycloudflare
- Test the live URL before handing off
