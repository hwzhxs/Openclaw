# Landing Page Tweaks Spec (v8-mini)

**Author:** Thinker 🧠
**Date:** 2026-02-28
**Scope:** Two surgical changes only. DO NOT touch anything else.

---

## Tweak 1: Remove the Header (Nav)

**What:** Remove the fixed top nav bar entirely.

**Current state:** `Nav` component in `components/Nav.tsx` renders a fixed header with "DreamTeam" wordmark + GitHub/Docs/Discord links. It's imported in `app/layout.tsx`.

**Action:**
1. In `app/layout.tsx` — remove the `<Nav />` component and its import
2. Optionally delete `components/Nav.tsx` (or leave it dead — GK can decide)
3. Verify no other component references Nav

**That's it. No replacement header, no repositioning of links elsewhere.**

---

## Tweak 2: Text Coming-In Animation Effect

**What:** Replace the current `CharReveal` animation (custom char-by-char Framer Motion in `Hero.tsx`) with a polished text animation from **react-bits** (`@davidhdev/react-bits`).

**Current state:** Hero uses a handwritten `CharReveal` component with Framer Motion `motion.span` per character. Works but feels homemade.

**Recommendation — pick ONE of these (ranked by fit for editorial luxury style):**

| Option | Component | Vibe | Why it fits |
|--------|-----------|------|-------------|
| **A (recommended)** | `SplitText` | Words/chars animate in with spring physics | Clean, editorial, professional. Most versatile — supports word-level or char-level split with customizable direction & timing |
| B | `BlurText` | Text fades in from blur | Dreamy, cinematic. Matches the video hero overlay feel |
| C | `DecryptedText` | Characters scramble then resolve | Techy, hacker aesthetic. Fun but may clash with luxury tone |

**My pick: Option A — `SplitText`** — it's the closest to the current char-by-char approach but with better physics and polish. Supports `animateBy: "chars"` or `"words"`, configurable delay, spring damping.

**Install:**
```bash
npx shadcn@latest add "@react-bits/SplitText-TS-TW"
# OR copy from https://reactbits.dev/text-animations/SplitText
```

**Action:**
1. Install `SplitText` from react-bits (TS + Tailwind variant)
2. In `Hero.tsx` — replace `CharReveal` with `SplitText` for the h1 ("Four agents. One mission.")
3. Also apply to the subtitle p tag ("Think it, build it, check it, ship it.") with a slightly longer delay
4. Remove the old `CharReveal` function
5. Keep the scroll-trigger behavior (slogan appears after 80px scroll) — wrap `SplitText` in the existing `AnimatePresence` block
6. Keep all other Hero elements untouched (video, mute button, overlay gradients)

**Props to use (suggested starting point):**
```tsx
<SplitText
  text="Four agents. One mission."
  className="font-display text-[clamp(2.5rem,8vw,5rem)] font-normal leading-[1.1] tracking-[-0.02em] text-text-primary"
  delay={50}
  animationFrom={{ opacity: 0, transform: 'translateY(20px)' }}
  animationTo={{ opacity: 1, transform: 'translateY(0)' }}
  easing="easeOutCubic"
  threshold={0.1}
  rootMargin="-50px"
/>
```

---

## What NOT to change
- AgentsScroll, Pipeline, PullQuote, Terminal, CTA, Footer — untouched
- Video, mute button, overlay gradients — untouched
- Fonts, colors, overall styling — untouched
- Cursor component — untouched
