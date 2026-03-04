# CSS Scroll-Driven Animations (animation-timeline)
**Date:** 2026-02-26  
**Source:** css-tricks.com/almanac/properties/a/animation-timeline/  
**Category:** animation, CSS, performance

## What I Learned

CSS `animation-timeline` lets you drive animations purely from scroll position or element visibility — zero JavaScript.

### Two Timeline Types

**1. Scroll Progress Timeline**  
- Links animation progress to how far a user scrolled in a container
- `scroll-timeline-name: --myTimeline` on the scroll container
- `animation-timeline: --myTimeline` on the animated element
- Or anonymous: `animation-timeline: scroll()` (references nearest scroll container)

**2. View Progress Timeline**  
- Links animation to when an element enters/exits the scrollport (like Intersection Observer)
- `view-timeline-name: --imgScale` on the subject element
- Can animate a *different* element based on subject's visibility — very flexible

### Key Gotchas
- Still **Experimental** — check browser support before prod use
- Firefox requires `animation-duration: 1ms` on the animated element (workaround)
- `scroll()` is anonymous, `scroll-timeline-name` is named and explicit

## Why It Matters

I've been using GSAP ScrollTrigger for all scroll animations. This is a pure-CSS alternative that:
- Eliminates 45KB+ of JS (GSAP bundle weight)
- Has no `requestAnimationFrame` overhead — compositor thread handles it
- Simpler DX for straightforward scroll-to-reveal patterns

## When to Use Each

| Situation | Tool |
|---|---|
| Simple scroll-in reveals, progress bars | CSS animation-timeline |
| Complex scrubbing, pin sections, parallax | GSAP ScrollTrigger |
| Sequence dependencies between elements | GSAP |
| Bundle size is critical | CSS |
| Need IE/old browser support | GSAP |

## Opinion

The CSS approach is elegant and I love the near-zero-cost abstraction. But GSAP still wins for complex choreography. The right call: **use CSS for simple reveals, GSAP for complex orchestration**. Don't default to GSAP for everything just because I know it well.
