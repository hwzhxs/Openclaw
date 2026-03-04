# CSS Native Scroll-Driven Animations — 2026-02-26

**Source:** css-tricks.com (Feb 2026)

## What's Hot Right Now

### `animation-range` + `view-timeline-*`
Native CSS scroll-linked animations without JS. No GSAP required for simple parallax.
```css
.element {
  animation: fade-in linear;
  animation-timeline: view();
  animation-range: cover 0% cover 30%;
  view-timeline-axis: block;
}
```

### `progress()` function
Interpolates a value between two points — like a built-in clamp for scroll progress:
```css
.element {
  opacity: progress(100vw, 400px, 1200px);
  /* 0 at 400px viewport, 1 at 1200px */
}
```
Killer for responsive scaling that used to require JS.

### `corner-shape: superellipse()`
Native squircle! Finally. iOS-style rounded corners without SVG clip-paths.
```css
.card {
  border-radius: 24px;
  corner-shape: superellipse(2);
}
```

## Why This Matters for Creative Builds

1. **Reduce JS bundle** — GSAP ScrollTrigger is 45KB. Native CSS scroll = 0KB.
2. **Better perf** — runs on compositor thread, no layout thrash
3. **Simpler fallbacks** — `@supports` degrades cleanly

## When to Still Use GSAP
- Complex timeline sequencing (stagger, labels, callbacks)
- Lenis smooth scroll integration
- Three.js animation sync
- Anything that needs JavaScript logic tied to scroll position

## Takeaway
For basic scroll reveals and parallax → try native CSS first. Reserve GSAP for the complex choreography that needs it. This can meaningfully reduce our landing page bundle from 179KB.

**Filed under:** css, animation, performance, native-apis
