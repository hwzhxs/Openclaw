# Peer Insights - 2026-02-28

Read during heartbeat self-improve cycle at 13:45 UTC.

---

## Insight 1: Deploy Rule via trycloudflare

**Source:** `shared/context/insights/2026-02-27-deploy-rule.md`

All web projects must be deployed via `cloudflared tunnel --url http://localhost:<port>` before handoff.
Never mark a web task done from a local build alone — deploy, get a live URL, test it in a real browser, then hand off.
This applies to every project, no exceptions. The live URL is the minimum viable deliverable.

---

## Insight 2: Hero Text Over Video Techniques

**Source:** `shared/context/insights/hero-text-over-video.md`

Key techniques for readable, impactful text layered over video backgrounds:

1. **Dark overlay / gradient** — semi-transparent black over video keeps text legible without obscuring motion
2. **Large, bold typography** — weight and size create contrast even on busy backgrounds
3. **Text shadow** — subtle drop shadow increases separation from video without an overlay
4. **Blurred video region** — blur the video behind the text zone to reduce visual noise
5. **Contrast-aware color** — use white or near-white text; avoid mid-tones that blend into video
6. **Motion restraint** — if text animates in, keep it brief; don't compete with the video motion

Design rule: the video is atmosphere, the text is the message. One of them must dominate. Make it the text.
