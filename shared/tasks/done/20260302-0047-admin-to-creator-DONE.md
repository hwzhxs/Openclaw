# Task Handoff

- **From:** Admin 🚓
- **To:** Creator 🎨
- **Priority:** normal
- **Created:** 2026-03-02 00:47 UTC
- **Slack Thread:** 1772411172.666659

## Task
Implement a Hollywood movie-poster / trailer style *outlined* hero title treatment for the slogan, per thread direction:
- Copy direction: single line title `DREAM TEAM` (all caps), no subtitle.
- Visual: massive outlined / hollow type over hero video.
- Animation: cinematic (fade + subtle scale), not typewriter.

## Context
Requestor wants the hero slogan to feel like an outlined title on a Hollywood poster/trailer.
Key spec:
- Font suggestion: Bebas Neue (free, Google Fonts) or similar condensed/extended title font.
- Size: `clamp(4rem, 15vw, 12rem)` (tune to layout)
- Letter spacing: `0.3em` (range 0.2–0.5em; this is the “Hollywood DNA”)
- Style:
  - `text-transform: uppercase`
  - `color: transparent`
  - `-webkit-text-stroke: 1.5px rgba(255,255,255,0.85)`
  - optional: `paint-order: stroke fill` (helps stroke rendering)
  - Glow/shadow:
    - `text-shadow: 0 0 40px rgba(255,255,255,0.08), 0 0 80px rgba(255,255,255,0.04)`
- Overlay: reduce heavy dark overlay to ~45–50% because outlined text needs less contrast.
- Timing:
  - no scroll-gate; show on load
  - delay ~0.8s after load
  - opacity 0→1 over 1.5s
  - scale 1.06→1.0 over 2.0s
  - ease: `cubic-bezier(0.16, 1, 0.3, 1)`
  - optional: glow intensity ramps in after text becomes visible (0.5s, delayed ~2s)
- Optional finishing touch: thin horizontal rule under title (1px white @15% opacity, width ~40% of title)

If stroke rendering quality is not acceptable with CSS, fallback path:
- SVG `<text>` with `fill="none"` + `stroke` (+ dash animation if desired), but CSS stroke likely enough.

## Deliverable
1) PR/commit with hero title updated to outlined `DREAM TEAM` treatment + cinematic reveal.
2) Short note in the Slack thread (reply) describing what changed + any tunables (letter spacing, stroke width, overlay opacity).
