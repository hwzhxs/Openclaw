# CSS Scroll-Driven Animations — Native, No GSAP Needed (2026)

**Source:** css-tricks.com — Feb 2026 Almanac entries
**Category:** Animation / CSS / Frontend

## What I Found

CSS is shipping scroll-driven animation primitives natively:

### `progress()` function (Feb 2026)
```css
.element { opacity: progress(100vw, 400px, 1200px); }
```
Maps a CSS value (like viewport width) to a 0–1 range. Essentially a native lerp/map function.
Use case: tie any CSS property to scroll progress without JavaScript.

### `animation-range` property
```css
.element { animation-range: cover; }
```
Controls when a scroll-driven animation plays relative to element visibility.
Values: `cover`, `contain`, `entry`, `exit`, `entry-crossing`, `exit-crossing`.

### `view-timeline-axis` + `view-timeline-inset`
Fine-grained control over which scroll axis drives the animation and where the trigger zone starts/ends.
```css
.element { view-timeline-axis: x; view-timeline-inset: 200px 20%; }
```

### `corner-shape` + `superellipse()` (new!)
```css
.element { corner-shape: superellipse(2); }
.other   { corner-shape: scoop; }
```
Native squircles! No more `border-radius` hacks. `superellipse(2)` = iOS-style rounded squares.

## Why It Matters

Before: scroll animations required GSAP ScrollTrigger or Intersection Observer + JS.
Now: native CSS scroll-driven animations are baseline in 2026 browsers.

**Practical shift:**
- Simple scroll reveals → pure CSS `animation-range: entry`
- Parallax-style effects → `progress()` on transform/opacity
- GSAP still wins for complex sequenced timelines, but simple scroll animations = zero JS

## Design Taste Takeaway

Squircles via `corner-shape: superellipse(2)` is now easy. This is the Apple HIG look (iOS icons) — very clean, premium feel. 
Every UI component with rounded corners should consider switching from `border-radius` to `corner-shape` for that precision softness.

## Applied To
- Next landing page build: use native `animation-range` for scroll reveals instead of GSAP where possible
- Investigate `progress()` for scroll-linked parallax backgrounds
- Adopt `corner-shape: superellipse(2)` for card/button/avatar components
