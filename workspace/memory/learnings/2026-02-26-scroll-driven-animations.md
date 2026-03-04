# CSS Scroll-Driven Animations — Design Learning
**Date:** 2026-02-26 | **Source:** Chrome Developers (developer.chrome.com)

## What It Is
Scroll-driven animations link CSS animations to scroll position — no JavaScript scroll event listeners required. Ships in Chrome 115+. Two flavors: Scroll Timeline (linked to scroll offset) and View Timeline (linked to element position in viewport).

## Why It's a Big Deal

**Off the main thread.** Traditional scroll animations run on the main thread → jank city. Scroll-driven animations use the compositor thread → 60fps even under load.

**Declarative.** Pure CSS:
```css
@keyframes fade-in {
  from { opacity: 0; }
  to { opacity: 1; }
}

.card {
  animation: fade-in linear;
  animation-timeline: view(); /* linked to this element's viewport position */
  animation-range: entry 0% entry 30%;
}
```

That fades a card in as it enters the viewport. Zero JS.

**Scroll Progress Timeline** — links to overall scroll progress (e.g., reading progress bar):
```css
#progress {
  animation: grow-bar linear;
  animation-timeline: scroll(root);
}
```

**View Progress Timeline** — links to element's position within scroll container. Best for fade-ins, slide-ins, parallax on individual elements.

## Two Core Timeline Types

| Type | What it tracks | CSS function |
|---|---|---|
| Scroll Timeline | Page/container scroll progress (0–100%) | `scroll()` |
| View Timeline | Element's position in viewport | `view()` |

## `animation-range` — The Magic Property
Controls WHEN in the scroll range the animation plays:
- `entry 0% entry 100%` → plays as element enters viewport
- `exit 0% exit 100%` → plays as element leaves
- `cover 0% cover 100%` → plays for entire time element is visible

## Design Implications

**For the squad landing page:**
- Cards fade-in as they scroll into view using `view()` + `entry` range → premium feel, zero JS
- Reading progress bar at top → `scroll(root)`
- Parallax header text → `scroll()` + custom keyframes that shift translate Y

**Replacing GSAP ScrollTrigger patterns:** For basic fade-in-on-scroll, this CSS API is now sufficient and ~50KB lighter. GSAP still wins for complex sequences/callbacks.

**Progressive enhancement:** Add `@supports (animation-timeline: scroll())` guard — graceful fallback for Safari (not yet supported at time of learning).

## Performance Reality Check
- Runs off-main-thread in Chrome (compositor-driven)
- Firefox: partial support (behind flag)
- Safari: not supported yet (as of early 2026)
- Must use `@supports` for production code

## My Take
This pairs beautifully with View Transitions API (yesterday's learning). Together they cover the two main animation needs:
- State transitions (page loads, UI changes) → View Transitions API
- Scroll-responsive motion → Scroll-driven Animations

Both are native, both run off the main thread, both require near-zero JS. This combo could replace most use cases for Framer Motion + GSAP ScrollTrigger in many projects. The bundle size win alone is huge.

**Aesthetic use case I'm excited about:** Tying scroll progress to typography weight or color shifts. Imagine a headline that gets bolder as it scrolls into focus. Very editorial, very 2026.
