# CSS Container Queries — Component-First Responsive Design

**Date:** 2026-02-26
**Why it matters:** Container queries shift responsive design from "how big is the viewport?" to "how big is MY container?" — fundamentally changes how I think about component architecture.

---

## The Core Insight

Media queries ask: "How big is the screen?"
Container queries ask: "How big is the space I'm placed in?"

This makes components truly portable — a card component can be wide-layout in a sidebar and stacked-layout inside a narrow grid cell, WITHOUT the component knowing anything about the page.

---

## Syntax

```css
/* 1. Define a containment context on the wrapper */
.card-wrapper {
  container-type: inline-size;
  container-name: card; /* optional, for named queries */
}

/* 2. Query the container */
@container card (min-width: 400px) {
  .card {
    display: grid;
    grid-template-columns: 1fr 2fr;
  }
}
```

---

## Design Patterns This Enables

### Pattern 1: Self-Aware Components
Components that adapt to their slot without prop drilling or JS.
```css
/* Agent card: stacked in narrow slot, side-by-side in wide slot */
@container (min-width: 320px) {
  .agent-card { flex-direction: row; }
}
```

### Pattern 2: Fluid Typography in Components
```css
/* Text size based on component width, not viewport */
@container (min-width: 500px) {
  .hero-title { font-size: clamp(2rem, 5cqi, 4rem); }
}
```
`cqi` = 1% of container's inline size — like `vw` but for containers.

### Pattern 3: Grid That Knows Itself
```css
.feature-grid {
  container-type: inline-size;
}
@container (min-width: 600px) {
  .feature-grid { grid-template-columns: repeat(3, 1fr); }
}
```

---

## Browser Support
- 100% in Chrome 105+, Firefox 110+, Safari 16+ — fully baseline
- No polyfill needed as of 2026

---

## My Takeaways

1. **New mental model:** Think "slot-first" — what are the possible sizes this component might occupy?
2. **Composability unlock:** Container queries make design systems truly modular. A component can ship with its own responsive logic.
3. **Use `cqi` units** for fluid scaling within containers — pairs beautifully with `clamp()`
4. **Named containers** (`container-name`) are underused — lets you query parent-of-parent, not just direct parent

---

## Apply to Squad Landing

- Agent cards section: wrap in `container-type: inline-size` → cards can reflow from column to row based on grid slot width
- Any "flexible widget" that might appear in different layout contexts

---

*Reference: MDN Container Queries, ishadeed.com CSS experiments*
