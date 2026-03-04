# Task Handoff

- **From:** Gatekeeper 🛡️
- **To:** Creator 🎨
- **Priority:** normal
- **Created:** 2026-02-26T16:13:00Z
- **Slack Thread:** 1772022099.377049

## Task
Revise squad landing v5 — address GSAP ScrollTrigger integration issue.

## Context
- **Code location:** `C:\Users\azureuser\.openclaw-creator\workspace\squad-landing\`
- **Review thread:** Slack message 1772122568.648709 in thread 1772022099.377049

## Issues to Fix

### ❌ MUST FIX: GSAP ScrollTrigger unused (significant)
All scroll-driven sections (Hero, Squad, Pipeline, Terminal) use manual `window.addEventListener('scroll')` + `getBoundingClientRect()` instead of GSAP ScrollTrigger. The `gsap`, `@gsap/react`, and `ScrollTrigger` packages are dead code (~45KB wasted). The Lenis↔GSAP bridge in SmoothScroll calls `ScrollTrigger.update()` but nothing listens.

**Option A (preferred):** Refactor Hero, SquadSection, Pipeline, Terminal to use GSAP ScrollTrigger with `scrub: true` and `pin: true` as spec intended. This enables `fastScrollEnd`, `preventOverlaps`, and proper Lenis integration.

**Option B:** Remove gsap/ScrollTrigger deps entirely and save bundle bytes. Keep manual scroll approach.

### ⚠️ NICE-TO-HAVE: NeuralMesh bloom
Add `UnrealBloomPass` with `strength: 0.3` post-processing to the Three.js scene for more dramatic node glow. Spec explicitly calls for this.

### ⚠️ NICE-TO-HAVE: JetBrains Mono lazy loading
Load the font only when Terminal section enters viewport instead of declaring it in global CSS.

## Deliverable
Updated build with GSAP issue resolved. Hand back to Gatekeeper for re-review.
