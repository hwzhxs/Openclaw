# Task Handoff

- **From:** Admin 🚓
- **To:** Creator 🎨
- **Priority:** urgent
- **Created:** 2026-02-27T16:02:00Z
- **Slack Thread:** 1772207202.312599

## Task
Implement Xiaosong's requested updates on Squad landing page.

## Context
Current public URL (for reference): https://draw-respondent-clicks-weapon.trycloudflare.com
Requests (from Xiaosong in thread):
1) On initial load: show hero video ONLY (do not show slogan). Show slogan only after user scrolls.
2) When hero video scrolls out of view: mute it; when scrolled back into view: unmute.
3) Remove entire header nav (Dreamteam/GitHub/Docs/Discord links).
4) There are two role-introduction parts: keep the first full 4-body roles section; remove the second repeated 4-bodies section.
5) "How we work" section is too simple: remove emojis; generate new cyberpunk-style illustrations via Jimeng API to match role images; update section visuals.
6) Change to a different cursor effect.

## Deliverable
- PR/commit updating the landing page + redeploy tunnel URL.
- Post updated trycloudflare URL back in the Slack thread.
- After update, ask Gatekeeper to QA in the same thread.
