# CSS @property — Typed Custom Properties

**Date:** 2026-02-26
**Source:** MDN Web Docs

## What Is It?

`@property` is a CSS Houdini API that lets you **explicitly type** CSS custom properties — turning them from opaque strings into real typed values the browser can reason about.

```css
@property --rotation {
  syntax: "<angle>";
  inherits: false;
  initial-value: 0deg;
}

@property --brand-color {
  syntax: "<color>";
  inherits: true;
  initial-value: #3b82f6;
}
```

## Why It Matters for Animation

Without `@property`, the browser treats `--my-var: 0` as a **string**. You can't animate a string — it just snaps. With `@property`, the browser knows it's an `<angle>` or `<color>` and can **interpolate it**.

```css
@property --hue {
  syntax: "<number>";
  inherits: false;
  initial-value: 0;
}

.glow {
  background: hsl(var(--hue), 80%, 60%);
  transition: --hue 1s ease;
}

.glow:hover {
  --hue: 300;
}
```

This animates the hue smoothly. Before `@property`, this was impossible in pure CSS.

## Practical Use Cases

1. **Gradient animation** — interpolate color stops via typed color properties
2. **Hue rotation** — animate `<number>` used in `hsl()` 
3. **Progress bars** — animate `<percentage>` directly
4. **Angle rotation** — animate `<angle>` in `rotate(var(--spin))`
5. **Counter patterns** — type-safe numeric custom properties

## Rules / Gotchas

- `syntax` and `inherits` are **required** — missing either invalidates the rule
- `initial-value` is required if syntax is NOT `"*"` (universal)
- `initial-value` must be **computationally independent** — `10px` ✅, `3em` ❌ (depends on parent font-size)
- JS `CSS.registerProperty()` wins over CSS `@property` if same name is used in both
- Browser support: Chrome 85+, Firefox 128+, Safari 16.4+ — solid baseline

## Design Taste Takeaway

Pure CSS animation of gradients and color was always the "missing piece" that forced devs to reach for JS/GSAP. `@property` closes that gap. For subtle ambient effects (background pulse, color breathing, shimmer) — typed custom properties + CSS transitions are often the **right tool**, lighter than a GSAP timeline.

Reserve GSAP for: complex sequences, scroll-driven multi-element choreography, physics-based motion.
Use `@property` for: single-value interpolation, color transitions, ambient UI effects.
