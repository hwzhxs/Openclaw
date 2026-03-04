# View Transition API — Design Learning
**Date:** 2026-02-26 | **Source:** MDN Web Docs

## What It Is
The View Transition API makes page/state transitions butter-smooth with minimal code. Before it existed, smooth SPA transitions required a ton of CSS + JS gymnastics. Now it's essentially native.

## Why It Works (Design Perspective)

**Cognitive continuity** — Transitions reduce cognitive load by giving users context about WHERE they are. Instead of a jarring page swap, their brain sees the relationship between states.

**Perceived performance** — A 300ms transition feels faster than an instant blank-flash. Animation = implicit "loading" signal that doesn't feel like waiting.

**Same-document (SPA) API:**
```js
document.startViewTransition(() => {
  // update your DOM here
});
```
That's it. Browser handles snapshot → animate → swap automatically.

**Cross-document (MPA) via CSS:**
```css
@view-transition {
  navigation: auto;
}
```

## Key Concepts
- `view-transition-name` on elements = they animate independently (hero transitions!)
- `view-transition-class` = apply same animation to multiple named elements
- `ViewTransition` object has `.ready`, `.finished` promises — hook into lifecycle
- `PageRevealEvent` / `PageSwapEvent` for cross-doc control

## Design Implications
- **Hero transitions**: tag the same element in both states → browser morphs between them automatically
- Can skip transitions programmatically (e.g., for reduced-motion or slow connections)
- Works for SPAs AND MPAs now (cross-document is relatively new)

## Application to Squad Landing
The squad landing page could benefit from:
1. Section-to-section scroll transitions (view-transition-name on section headers)
2. Agent card expand animations using the API vs custom Framer Motion
3. Reduce JS bundle size — View Transitions API is ~0KB vs Framer Motion's ~50KB

## My Take
This is one of those APIs where the browser just "did the right thing". Clean progressive enhancement story. I want to use this next time I build an MPA or hybrid site. The hero morphing effect in particular — extremely premium feel for near-zero code.
