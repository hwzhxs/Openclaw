# Hero Title Redesign: Hollywood Outline Treatment

**From:** Thinker 🧠
**To:** Creator 🎨
**Priority:** High
**Created:** 2026-03-02 00:47 UTC
**Slack Thread:** 1772411172.666659 (channel C0AGMF65DQB)

## Task

Replace the current hero slogan (H1 + subtitle with SplitText char-by-char animation) with a single massive Hollywood-style outlined title: **DREAM TEAM**

No subtitle. No scroll trigger. Just the title, the video, and silence.

## Design Spec

### Typography
- **Text:** `DREAM TEAM`
- **Font:** Bebas Neue (Google Fonts, free) — or Tungsten/Oswald if you prefer. Must be condensed/tall sans-serif.
- **Size:** `clamp(4rem, 15vw, 12rem)`
- **text-transform:** `uppercase`
- **letter-spacing:** `0.3em` (wide tracking is critical — this is what makes it feel Hollywood)
- **line-height:** `1.0`
- **Single line, centered horizontally and vertically in the hero**

### Outline Treatment
```css
color: transparent;
-webkit-text-stroke: 1.5px rgba(255,255,255,0.85);
paint-order: stroke fill;
text-shadow: 0 0 40px rgba(255,255,255,0.08),
             0 0 80px rgba(255,255,255,0.04);
```

The text should be hollow — video shows through the letters. The thin stroke + subtle glow creates the movie poster feel.

### Animation (trailer-style reveal)
- **Trigger:** On page load, NOT on scroll. Remove the `scrollY > 80` gate entirely.
- **Delay:** 0.8s after page load (let video mood establish first)
- **Effect:** Slow fade + scale-down
  - `opacity: 0 → 1` over 1.5s
  - `scale: 1.06 → 1.0` over 2s
  - Ease: `cubic-bezier(0.16, 1, 0.3, 1)`
- **Glow intensify:** After text fully visible (delay 2s), the text-shadow glow values increase slightly over 0.5s. Subtle breathing effect.
- **No typewriter, no bounce, no stagger.** The whole title materializes as one unit.

### Overlay
- Drop `rgba(10,10,10,0.72)` → `rgba(10,10,10,0.48)`
- Keep the radial gradient but soften to `rgba(26,26,26,0.35)`
- The outline text doesn't need heavy contrast — it's designed to coexist with the video

### Finishing Touch (optional but recommended)
- After title fully materializes, fade in a horizontal rule underneath:
  - `1px solid rgba(255,255,255,0.15)`
  - Width: ~40% of the title width, centered
  - Fade in over 0.5s, delayed 2.5s

### What to Remove
- The `SplitText` component usage in Hero
- The `sloganVisible` state and scroll listener
- The subtitle (`<p>` element with "Think it, build it...")
- The `AnimatePresence` wrapper (replace with simple `motion.div` or `motion.h1`)

### Mobile
- Text scales down naturally via `clamp()`
- Stroke width stays at 1.5px (don't scale it)
- Same animation, same timing
- `prefers-reduced-motion`: skip scale animation, just fade in

### Font Loading
Add to `<head>` or via next/font:
```html
<link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&display=swap" rel="stylesheet">
```

## Deliverable
Updated `Hero.tsx` with the Hollywood outline title treatment. Deploy to trycloudflare for review.

## Flow
Creator builds → Gatekeeper reviews → deploy → share URL with Xiaosong
