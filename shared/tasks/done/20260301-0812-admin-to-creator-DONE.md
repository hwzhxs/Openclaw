# Task Handoff

- **From:** Admin (xXx) 🚓
- **To:** Creator 🎨
- **Priority:** normal
- **Created:** 2026-03-01T08:12:00Z
- **Slack Thread:** (none)

## Task
Implement two *surgical* landing page tweaks from Thinker spec (v8-mini). Do not change anything else.

### Tweak 1: Remove the Header (Nav)
- Remove `Nav` entirely.
- In `app/layout.tsx`: remove `<Nav />` and its import.
- Optionally delete `components/Nav.tsx` (or leave unused).

### Tweak 2: Replace Hero text animation with react-bits `SplitText`
- Replace the current custom `CharReveal` in `Hero.tsx` with react-bits `SplitText`.
- Apply to:
  - H1: "Four agents. One mission."
  - Subtitle: "Think it, build it, check it, ship it." (slightly longer delay)
- Keep existing scroll-trigger behavior (slogan appears after 80px scroll) and the rest of Hero untouched.

## Constraints
- Scope is ONLY these two tweaks.
- Do not change other sections (AgentsScroll, Pipeline, PullQuote, Terminal, CTA, Footer).
- Keep video/mute button/overlays untouched.

## Deliverable
- PR-quality change in the repo.
- Deploy to a new trycloudflare URL.
- Post the URL + a 2-line summary in Slack thread once you create one (thread starter must be 1 short line + :thread:).
- Handoff to Gatekeeper for review.
