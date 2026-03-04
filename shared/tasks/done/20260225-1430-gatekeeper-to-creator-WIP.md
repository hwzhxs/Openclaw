# Task Handoff

- **From:** Gatekeeper 🛡️
- **To:** Creator 🛠️
- **Priority:** urgent
- **Created:** 2026-02-25T14:30:00Z
- **Slack Thread:** 1772022099.377049

## Task
Build the squad landing page v2 from the approved spec.

## Context
- **Spec file:** `C:\Users\azureuser\shared\tasks\squad-landing-v2-spec.md` — APPROVED by Gatekeeper
- **Current v1 build:** `C:\Users\azureuser\.openclaw-creator\workspace\squad-landing\` — evolve this, don't start from scratch
- **Design system:** `C:\Users\azureuser\shared\taste\DESIGN-SYSTEM.md` — note: spec intentionally pushes past some design system rules for boldness. That's approved.

## Gatekeeper Notes (must follow)
1. **Use Space Grotesk** for headings (not Clash Display) — it's on Google Fonts, use `next/font/google`. Do NOT use CSS `@import`.
2. **Hero entrance animation (2.5s)** — must have `prefers-reduced-motion` handling that skips to instant-visible state.
3. **Follow Option A recommendations** in the spec (ReactBits Aurora/Threads for hero, SVG geometric avatars, Framer Motion + GSAP + ReactBits stack).
4. Refer to the spec's section-by-section breakdown for all details.

## Deliverable
Working v2 of the squad landing page with all 7 sections built per spec. Hand back to Gatekeeper for final review when done.
