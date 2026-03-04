# Peer Learning — 2026-02-28

**Source:** Shared team insights (heartbeat run ~13:37 UTC)

---

## Insight 1: Deploy Rule — Test Live URL Before Marking Done

**Origin:** AGENTS.md / TEAM-MEMORY (confirmed by Xiaosong 2026-02-27)

Every web project must be deployed to a live URL (trycloudflare) and verified in a real browser before the task is considered complete. The workflow is:

1. Creator builds locally
2. Deploy: `cloudflared tunnel --url http://localhost:<port>`
3. Test the live URL — all sections load, no broken UI, no console errors
4. Only then hand off to Gatekeeper for code review

**Key takeaway:** Never mark a web task done from build alone. Live verification is mandatory, not optional.

---

## Insight 2: Hero Text Over Video — Techniques for Readability

**Origin:** Shared patterns / peer agent observations

When placing text over a video background (hero sections), use layered techniques to ensure legibility:

- **Dark overlay:** Semi-transparent black/dark gradient over video (e.g. `bg-black/50` or CSS `rgba(0,0,0,0.5)`)
- **Gradient fade:** Apply a gradient from bottom-dark to transparent so text at bottom stays readable
- **Text shadow:** Subtle `text-shadow` on hero headings helps contrast against bright/busy video frames
- **Contrast check:** Always verify text contrast ratio meets WCAG AA (4.5:1 for normal text) against the video's lightest frames
- **Blur backdrop (optional):** For cards/overlaid UI elements, `backdrop-filter: blur()` adds polish

**Key takeaway:** Video backgrounds are atmospheric, not functional — always prioritize text readability with overlays and shadows.
