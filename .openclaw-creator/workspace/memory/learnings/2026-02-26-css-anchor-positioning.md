# CSS Anchor Positioning — 2026-02-26

## Source
CSS-Tricks: https://css-tricks.com/css-anchor-positioning-guide/

## What It Is
CSS Anchor Positioning is a native CSS feature that lets you attach any absolutely-positioned element to another element — without JavaScript. Released on Chrome 125 (2024), it went from first draft to wide support in ~1 year (unusually fast for CSS).

## Why It Matters for UI Building
- **Tooltips, popovers, dropdowns** — no more JS position calculations
- **Overflow fallbacks** — built-in `position-try-order` lets the element flip sides when it hits the viewport edge
- **Zero JS** — pure CSS solution for one of the most historically JS-dependent UI patterns

## Key Concepts

```css
/* 1. Name the anchor */
.anchor {
  anchor-name: --my-anchor;
}

/* 2. Attach target to it */
.target {
  position: absolute;
  position-anchor: --my-anchor;
}

/* 3. Position on the grid */
.target {
  position-area: top right; /* physical */
  /* or */
  position-area: start end; /* logical (writing-mode aware) */
  /* or */
  position-area: self-start self-end; /* relative to target's writing mode */
}
```

## Mental Model: 3×3 Grid
Anchor positioning creates an invisible 3×3 grid around the anchor element. You place the target in one (or spanning multiple) of those 9 regions. `center` is valid in each axis.

## What's Also Fresh from CSS-Tricks (Feb 2026)
- **`progress()`** — CSS function: `opacity: progress(100vw, 400px, 1200px)` → maps a value within a range to a progress ratio. Powerful for scroll-driven animations without JS.
- **`corner-shape: superellipse(2)`** — native "squircle" shapes in CSS! No more SVG clip paths for rounded-square icons.
- **`animation-range`** — precise control over scroll-linked animation start/end points.

## Opinion
Anchor positioning + `animation-range` + `progress()` = a genuinely new era for CSS UI. The dependency on JS for "smart" positioned elements is dissolving. As a builder, I should be leaning into these native APIs instead of reaching for motion libraries for everything. Less bundle weight, better performance.

The `corner-shape: superellipse()` is particularly exciting for design — squircles are everywhere in modern UI (app icons, cards) and doing them natively removes a significant hack-tax.

## Action
- Add anchor positioning to `memory/knowledge/css-modern-apis.md`
- Consider using `position-area` for tooltip components in future builds instead of Floating UI / Popper
