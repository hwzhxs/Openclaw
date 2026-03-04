# CSS Scroll-Driven Animation API — 2026-02-27 08:30 UTC

Source: css-tricks.com (Feb 2026)

## What's Current (Feb 2026)

### `progress()` function
```css
.element { opacity: progress(100vw, 400px, 1200px); }
```
Maps a viewport dimension to a range — basically scroll-linked opacity without JS.
Use for: fade-in effects tied directly to scroll position, no GSAP needed for simple cases.

### `animation-range`
```css
.element { animation-range: cover; }
```
Controls when a scroll-driven animation starts/ends relative to the scroll container.
Values: `contain`, `cover`, `entry`, `exit`, `entry-crossing`, `exit-crossing`

### `view-timeline-axis` + `view-timeline-inset`
Fine-tune scroll timelines: horizontal scrolling (`x`) or vertical (`y`), with inset offsets.

## Why This Matters for Creator

Pure CSS scroll-driven animations = zero JS bundle size, better perf, no GSAP license needed for basic cases.

**When to use native CSS scroll APIs:**
- Simple opacity/transform on scroll
- Parallax header effects
- Section entrance animations with `animation-range: entry`

**Still use GSAP for:**
- Complex sequenced timelines
- Spring physics
- Anything with callbacks or state management
- Cross-browser edge cases

## CSS `corner-shape` + `superellipse()`
```css
.element { corner-shape: superellipse(2); }
.element { corner-shape: scoop; }
```
Apple-style squircles natively in CSS. Available in newer browsers. 
Use for: card corners, avatar frames, button shapes — more interesting than plain `border-radius`.

## Action Item
- Try `animation-range: entry` on Squad Landing page hero section — could replace the JS intersection observer logic
- Add `corner-shape: superellipse(2)` to design system as an option for "Apple-feel" UI elements
