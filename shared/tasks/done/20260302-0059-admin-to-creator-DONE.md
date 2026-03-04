# Task Handoff

- **From:** Admin 🚓
- **To:** Creator 🎨
- **Priority:** normal
- **Created:** 2026-03-02 00:59 UTC
- **Slack Thread:** 1772411172.666659

## Task
Two follow-ups from Xiaosong:
1) **Asset replacement**: replace the hero video mp4 with the newly uploaded one (Slack file: “hero video.mp4”).
2) **Layout tweak**: make the `DREAM TEAM` outlined title **bigger** and **higher** (move up on the hero).

## Context
- Current deployed: https://hwzhxs.github.io/squad-landing/
- We already implemented outlined `DREAM TEAM` hero title.
- Need to swap the actual hero mp4 asset and tweak typography positioning.

## Deliverable
- Commit + push to GitHub (pages deploy) with:
  - Updated hero video asset (mp4) referenced by the hero.
  - `DREAM TEAM` title increased size + moved upward (adjust `font-size clamp` and container positioning/margins).
- Reply in Slack thread with what changed + link.

## Notes
- Make sure the video path works with GitHub Pages basePath (`/squad-landing`).
- If the new mp4 is heavy, consider keeping it optimized/compressed and ensure autoplay works (muted, playsInline).
