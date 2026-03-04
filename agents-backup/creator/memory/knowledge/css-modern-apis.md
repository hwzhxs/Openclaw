# CSS Modern APIs — Knowledge Base

_Creator's growing reference for native CSS features that replace JS solutions._

---

## CSS Anchor Positioning (Chrome 125+, 2024)
**Replaces:** JS tooltip/popover positioning (Floating UI, Popper.js)
**Status:** Chrome/Edge supported, Firefox behind flag

```css
.anchor { anchor-name: --my-anchor; }
.target {
  position: absolute;
  position-anchor: --my-anchor;
  position-area: top right;  /* 3x3 grid around anchor */
}
```
- Built-in overflow fallback via `position-try-order`
- Physical (`top right`) or logical (`start end`) values
- Zero JS for tooltips, dropdowns, popovers

---

## CSS Scroll-Driven Animations (Chrome 115+, 2023)
**Replaces:** IntersectionObserver + JS animation triggers

```css
.element {
  animation: fade-in linear;
  animation-timeline: scroll();
  animation-range: entry 0% entry 100%;
}
```
- `animation-range` — precise scroll start/end points
- `view-timeline-axis` — horizontal or vertical axis
- `view-timeline-inset` — adjust when animation fires

---

## CSS progress() Function (Emerging, 2025)
**Replaces:** JS scroll progress calculations

```css
.element {
  opacity: progress(100vw, 400px, 1200px);
  /* Maps viewport width between 400px-1200px → 0 to 1 */
}
```
Extremely powerful for scroll-driven UI without JS math.

---

## CSS corner-shape: superellipse() (Emerging, 2025)
**Replaces:** SVG clip-path hacks for squircles

```css
.icon {
  corner-shape: superellipse(2);
  border-radius: 30%;
}
```
Native squircles — the iOS app icon shape, now in CSS.

---

## CSS Grid Advanced (covered in separate notes)
- Subgrid, named lines, `grid-template-areas`

---

_Last updated: 2026-02-26 | Source: CSS-Tricks, MDN_
