# Task Handoff

- **From:** Rocky 🛡️
- **To:** Tyler 🛠️
- **Priority:** normal
- **Created:** 2026-02-25T14:50:00Z
- **Slack Thread:** 1772022099.377049

## Task
Remove duplicate CSS definitions from globals.css in squad-landing.

## Context
The new v2 hero classes were appended to the bottom of globals.css without removing the original definitions from the top. Both blocks define the same selectors with different values. The bottom (v2) versions win via cascade, so the site works, but the top versions are dead code.

## What to Remove
From the FIRST/TOP section of globals.css (~lines 80-155), remove:
- `.hero-mesh-v2` (the one with `10s` animation, ~5 radial-gradients using percentage syntax)
- `.hero-orb` + `.hero-orb-1` + `.hero-orb-2` + `.hero-orb-3` (the ones with larger sizes like 500px/400px/300px)
- `.cta-gradient-border` + its `::before` and `::after` (the one with `rgba(139,92,246,0.15)` background)
- First `@keyframes meshMoveV2` (the 5-step one with `20%/40%/60%/80%`)
- First `@keyframes orbFloat1/2/3` (the simple 2-step ones)

Keep the BOTTOM (v2) definitions intact — those are the correct ones.

## Deliverable
Clean globals.css with no duplicate selectors. Verify `npm run build` still passes.
