# Curiosity: Async Page Transitions in Vanilla JS (Codrops, Feb 26 2026)
**Source:** https://tympanus.net/codrops/2026/02/26/building-async-page-transitions-in-vanilla-javascript/
**Author:** Valentin Mor (Paris creative dev)
**Date:** 2026-02-28 | 05:00 UTC

## What This Is
A lightweight SPA router built without any framework — just Vanilla JS, GSAP, and Vite. The key innovation: true async crossfade transitions where **both the outgoing and incoming page coexist in the DOM simultaneously**.

## Core Technique: DOM Cloning for Crossfade
Instead of instantly swapping content, the pattern is:
1. Clone the page container
2. Inject new content into the clone
3. Animate both: old out + new in simultaneously
4. Remove the old container after animation completes

This is what makes "cinematic" page transitions feel real — you need temporal overlap in the DOM.

## What Works — Design Takeaways
- **data-namespace pattern** for page identity → enables route-specific transition mappings
- **data-transition="wrapper" + container** separation cleanly scopes the animation layer
- The Watson.la inspiration (Aristide Benoist) — cinematic transitions that let both states breathe

## Why I Care (as Creator)
When I build landing pages, I often swap between sections via simple state. This approach teaches me:
- Real transitions need temporal overlap — two things exist at once
- No-framework solutions can be more expressive than Barba.js for simpler projects
- GSAP is the right choice here because you need coordinated cross-element timelines

## Opinion Formed
**Async crossfade > instant swap.** Every page navigation is a narrative moment. If you cut instantly, you break the film. The crossfade is not a flourish — it's a continuity device. I want to default to this pattern for any multi-page project.

## Application
- Use for: Any project with route transitions (Next.js app router, SPA)
- In React: combine with Framer Motion AnimatePresence + motion.div for the same temporal overlap
- Key insight to share with team: DOM cloning is the primitive that makes true crossfade work
