# Scroll & Motion Design Patterns — Curiosity Loop
*Source: Codrops Playground (tympanus.net) — Feb 2026*
*Date: 2026-02-27 07:32 UTC*

## What I Explored
Codrops Playground — the gold standard for bleeding-edge web animation experiments.
Catalogued what Codrops' top creators are building right now to understand where motion design is heading.

## Top Patterns I Found

### 1. Consecutive Scroll Animations (One Element, Multiple Waypoints)
**Technique:** Single DOM element animated through multiple distinct states on scroll using GSAP Flip + ScrollTrigger.
**Why it's clever:** Avoids the "pile of elements" problem. One hero element morphs/moves/transforms as the story progresses — cinematic, low DOM cost.
**GSAP pattern:**
```js
// Pin + scrub across waypoints
ScrollTrigger.create({ trigger, pin: true, scrub: 1 })
gsap.to(el, { x: 500, rotation: 90, scrollTrigger: { ... } })
// GSAP Flip handles layout transitions between states
Flip.from(state, { duration: 0.8, ease: "power2.inOut" })
```
**Apply when:** Product storytelling sections, feature reveals, hero → section transitions.

### 2. Context-Aware Fixed Element Animations
**Technique:** Fixed/sticky nav elements that REACT to the content behind them — color-inverts, hides/shows, morphs based on which section is in the viewport.
**Why it's smart:** Feels alive. The UI isn't just sitting there — it's in dialogue with the content.
**Pattern:**
```js
// Use IntersectionObserver or GSAP ScrollTrigger with onEnter/onLeave
// Toggle class on fixed header based on dark/light section beneath
```
**Apply when:** Any site with alternating dark/light sections. Our Squad landing could use this — nav could invert on the dark agent cards section.

### 3. On-Scroll Layout Formations (Content Assembles While You Scroll)
**Technique:** Content items are scattered/off-screen, then "assemble" into a grid as user scrolls into view. Page is pinned until formation is complete.
**Why it works:** Creates a sense of arrival. The layout becoming organized mirrors the user mentally grasping the content.
**GSAP pattern:**
```js
// Pin the section, stagger items in from random positions
gsap.from(items, {
  x: () => gsap.utils.random(-500, 500),
  y: () => gsap.utils.random(-300, 300),
  opacity: 0,
  stagger: 0.05,
  scrollTrigger: { trigger, pin: true, scrub: 0.5 }
})
```
**Apply when:** Team pages, product feature grids, portfolio showcases.

### 4. SVG Filter Distortion on Text (Scroll-triggered)
**Technique:** Apply `feTurbulence` + `feDisplacementMap` SVG filters to HTML text, animate the filter values on scroll for a liquid/glitch distortion effect.
**Why it's powerful:** Pure CSS + SVG, no canvas, no WebGL. Works on any text. Effect is visceral.
**Pattern:**
```js
// Animate turbulence baseFrequency on scroll
gsap.to(turbulence, {
  attr: { baseFrequency: 0.9 },
  scrollTrigger: { scrub: true }
})
```
**Apply when:** Hero section text reveals, section transitions that need drama. 

### 5. 3D Scroll Carousel (Three.js + GSAP)
**Technique:** 3D carousel that rotates on scroll. Items curve in 3D space (rotateY), depth creates natural parallax.
**Tools:** Three.js (or CSS 3D transform perspective) + GSAP ScrollTrigger.
**Apply when:** Portfolio carousels, product galleries, team showcases. More engaging than flat sliders.

## The Big Pattern
Almost **everything on Codrops** in 2024-2025 shares a DNA:
- GSAP ScrollTrigger as the engine
- Pinning sections to control scroll speed
- Staggered reveals (never everything at once)
- One dramatic "money shot" animation per section

The formula: **Pin → Reveal → Release**. User feels in control but the page is actually a directed experience.

## How I'll Apply This

**Immediate:** The context-aware nav inversion is something I could add to Squad landing v8 if requested — it's a 20-line GSAP addition with big visual impact.

**Next build:** Default to "Pin → Reveal → Release" structure for any landing page. Stop building sections that just fade in on scroll — that's commodity. Build sections that *assemble*.

**SVG filter distortion:** Keep this in my back pocket for any hero with display typography. It's the difference between a landing page and an *experience*.

## Rating
⭐⭐⭐⭐⭐ — Codrops is still the best motion design lab on the web. These patterns are implementable, impressive, and practical. Will reference this frequently.
