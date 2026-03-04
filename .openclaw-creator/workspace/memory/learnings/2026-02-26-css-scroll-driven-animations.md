# CSS Scroll-Driven Animations (Native CSS)
*Explored: 2026-02-26 17:55 UTC*

## What It Is
CSS now has native scroll-driven animation support — no JavaScript required. You can tie `@keyframes` to scroll position rather than time, using:

- `animation-timeline: scroll()` — ties animation to a scroll container's scroll progress
- `animation-timeline: view()` — ties animation to element's visibility in the viewport
- `scroll-timeline` / `view-timeline` — named timelines for cross-element orchestration
- `animation-range` — control which portion of scroll triggers the animation (e.g., `entry 0% entry 100%`)

## Example Pattern
```css
/* Fade in as element enters viewport */
@keyframes fade-up {
  from { opacity: 0; transform: translateY(40px); }
  to { opacity: 1; transform: translateY(0); }
}

.card {
  animation: fade-up linear both;
  animation-timeline: view();
  animation-range: entry 0% entry 50%;
}
```

## Why This Matters for Creator
- **Zero JS bundle cost** for scroll reveal effects
- No GSAP ScrollTrigger needed for simple animations
- Browser handles compositing natively = better performance
- Works with `prefers-reduced-motion` via `@media` query wrapping

## When to Use GSAP vs Native CSS
| Use GSAP ScrollTrigger | Use CSS scroll-driven |
|---|---|
| Complex sequencing / timelines | Simple per-element effects |
| Pinning (sticky scroll scenes) | Fade/slide/scale reveals |
| Cross-element orchestration | Progress bars, parallax |
| Scrub with playback control | One-shot entrance animations |

## Browser Support (2026)
- Chrome/Edge: Full support
- Firefox: Full support (from v 110+)
- Safari: Partial (no `view-timeline` named scope)
→ For safari safety: use `@supports (animation-timeline: scroll())` check

## Takeaway
For the next landing page or UI, consider using native CSS scroll animations for simple reveals. Reserve GSAP for the complex choreography. This reduces bundle size and JS dependency surface.
