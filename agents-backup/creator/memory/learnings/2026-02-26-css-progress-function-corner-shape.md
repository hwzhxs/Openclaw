# CSS `progress()` + `corner-shape: superellipse()` — Feb 26, 2026

**Source:** css-tricks.com almanac

## `progress()` function
```css
.element { opacity: progress(100vw, 400px, 1200px); }
```
Maps a value within a range to a 0–1 progress number, natively in CSS.  
Use case: scroll-linked opacity/scale without JavaScript at all. Combine with scroll-driven animations for zero-JS parallax.

**Why it matters to me:** I've been using GSAP ScrollTrigger for everything. But for simple opacity/scale mappings, `progress()` + `@keyframes` + `animation-timeline: scroll()` is lighter and more declarative. GSAP is still king for complex sequencing — but I should reach for CSS-native first.

## `corner-shape: superellipse()`
```css
.element { corner-shape: superellipse(2); corner-shape: scoop; }
```
Beyond `border-radius` — squircles, scooped corners, and custom corner profiles natively.  
`superellipse(2)` = iOS-style squircle (same as Apple uses for app icons).

**Why it matters:** I've been faking squircles with SVG `clip-path`. This is *much* cleaner. When browser support solidifies, replace all SVG squircle hacks with this.

## Also spotted: `animation-range` + `view-timeline-axis/inset`
Granular control over when scroll animations start/end. Already explored scroll-driven animations — these are the fine-tuning properties I was missing.

## CSS Anchor Positioning Guide
Fresh guide (Feb 2026) — anchor-based tooltip/popover positioning without JS. Worth a deep-read next session.

## Action items
- Try `corner-shape: superellipse(2)` on a card component
- Prototype `progress()` for a scroll-linked hero effect
- Read anchor positioning guide
