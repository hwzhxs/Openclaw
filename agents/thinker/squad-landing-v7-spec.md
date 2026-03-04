# Squad Landing Page — v7 Spec

> **Design Reference:** microsoft.ai
> **Vibe:** Editorial luxury. Dark, minimal, confident. Let typography and content breathe.

---

## 1. Design Philosophy

Microsoft.ai achieves premium feel through restraint: large editorial typography, generous whitespace, dark backgrounds, and almost no decorative elements. The content IS the design. No particles, no 3D, no scroll-jacking — just beautiful type, clean cards, and subtle motion.

**One-line principle:** *If microsoft.ai wouldn't do it, we don't do it.*

---

## 2. Color Palette

| Token | Value | Usage |
|---|---|---|
| `--bg-primary` | `#0a0a0a` | Page background |
| `--bg-card` | `#141414` | Card backgrounds |
| `--bg-card-hover` | `#1a1a1a` | Card hover state |
| `--text-primary` | `#f5f5f5` | Headlines, primary text |
| `--text-secondary` | `#999999` | Body text, descriptions |
| `--text-muted` | `#666666` | Labels, metadata |
| `--border` | `#222222` | Subtle card borders |
| `--border-hover` | `#333333` | Card border on hover |

**Agent accent colors** (muted, used sparingly as card gradient hints):

| Agent | Accent | Usage |
|---|---|---|
| Admin (Popo) | `#8B7355` | Warm bronze — subtle card gradient tint |
| Thinker (Kanye) | `#6B7B8D` | Slate blue — subtle card gradient tint |
| Gatekeeper (Rocky) | `#7D8471` | Sage green — subtle card gradient tint |
| Creator (Tyler) | `#8B6B7D` | Dusty mauve — subtle card gradient tint |

Agent accents appear ONLY as very subtle radial gradient overlays on their cards (opacity ~0.08). Never as text color, borders, or backgrounds.

---

## 3. Typography

**Font stack:**

| Role | Font | Weight | Size (desktop) | Size (mobile) |
|---|---|---|---|---|
| Display headline | **Playfair Display** (serif) | 400–500 | 64–80px | 36–44px |
| Section headline | **Playfair Display** (serif) | 400 | 40–48px | 28–32px |
| Pull quote | **Playfair Display** (serif, italic) | 400i | 32–40px | 24–28px |
| Body / UI | **Inter** (sans-serif) | 400 | 16–18px | 15–16px |
| Label / meta | **Inter** (sans-serif) | 500 | 12–14px | 11–13px |
| Code / terminal | **JetBrains Mono** | 400 | 14px | 13px |

**Typography rules:**
- Line height: 1.1 for display, 1.5 for body
- Letter spacing: `-0.02em` for display, `0` for body, `0.08em` for labels (uppercase)
- Max line width: `680px` for body text
- Load via `next/font` (no CSS @import)

**Why Playfair Display?** Microsoft.ai uses a serif display font for editorial weight. Playfair is open-source, has great italic for pull quotes, and pairs beautifully with Inter. Alternative: **Libre Baskerville** or **Lora** if Playfair feels too decorative.

---

## 4. Layout System

**Grid:** CSS Grid, max-width `1200px`, centered. Side padding `24px` mobile, `48px` tablet, `64px` desktop.

**Spacing scale:**
- Section gap: `160px` desktop, `96px` mobile
- Card gap: `16px`
- Card padding: `32px` desktop, `24px` mobile
- Card border-radius: `16px`

**Layout pattern** (following microsoft.ai):
```
┌─────────────────────────────────────────┐
│              NAV BAR                     │
├─────────────────────────────────────────┤
│                                         │
│         HERO (full-width text)          │
│     Large serif headline + subtitle     │
│                                         │
├─────────────────────────────────────────┤
│                                         │
│    AGENTS (2x2 bento grid of cards)     │
│                                         │
├─────────────────────────────────────────┤
│                                         │
│         PULL QUOTE (full-width)         │
│     Large italic serif + attribution    │
│                                         │
├─────────────────────────────────────────┤
│                                         │
│    PIPELINE (horizontal flow diagram)   │
│                                         │
├─────────────────────────────────────────┤
│                                         │
│    TERMINAL (code card, static)         │
│                                         │
├─────────────────────────────────────────┤
│                                         │
│         CTA (centered text + button)    │
│                                         │
├─────────────────────────────────────────┤
│              FOOTER                      │
└─────────────────────────────────────────┘
```

---

## 5. Section-by-Section Breakdown

### 5.1 Navigation

Minimal top bar. Fixed on scroll with subtle `backdrop-filter: blur(12px)` and background `rgba(10,10,10,0.8)`.

```
[Logo/Name]                              [About] [GitHub] [Contact]
```

- Logo: "SQUAD" in Inter 600, letter-spacing `0.12em`, uppercase, `14px`
- Links: Inter 400, `14px`, `--text-secondary`, hover → `--text-primary` with `transition: color 0.2s`
- Height: `64px`
- No hamburger on mobile — stack links or keep 2-3 max

### 5.2 Hero

Full-width, vertically centered (min-height `85vh`). Pure typography, no imagery.

**Content:**
```
Four agents. One mission.
```

- Font: Playfair Display, 80px desktop / 44px mobile
- Color: `--text-primary`
- Max-width: `900px`, centered
- Below headline: one-line subtitle in Inter 400, `18px`, `--text-secondary`
  - "Think it, build it, check it, ship it."
- **Background image:** `hero-bg.png` (即梦-generated cyberpunk command center), positioned as full-width cover with `opacity: 0.4` overlay of `#0a0a0a` to keep text readable
- Image path: `shared/assets/squad-images/hero-bg.png` → copy to `public/images/hero-bg.png`

**Animation:** Headline fades in + slides up 20px on load. Subtitle fades in 200ms later. That's it.

### 5.3 Agents (Bento Grid)

**Heading:** "The Team" — Playfair Display, 48px, centered, `--text-primary`
**Subhead:** "Each agent brings a different strength" — Inter 400, 18px, `--text-secondary`

**Layout:** 2×2 grid on desktop, single column on mobile.

**⚠️ Grid Uniformity Rule (mandatory):**
- Grid must be NEAT and symmetric — no orphan cards, no uneven rows
- Desktop: always `2×2` (all 4 cards same size, uniform gap)
- If card count changes: use `2×3`, `3×2`, or `2×2` — never `2-1`, `3-1`, or mixed-width rows
- Every row must have the same number of columns — no trailing single card
- All cards must be equal width within their row

Each card:
```
┌────────────────────────────────┐
│  🎤                            │  ← emoji, 32px
│                                │
│  Admin — Popo                  │  ← Inter 600, 20px, --text-primary
│  Coordinator                   │  ← Inter 400, 14px, --text-muted, uppercase, tracking 0.08em
│                                │
│  Orchestrates the team.        │  ← Inter 400, 16px, --text-secondary
│  Assigns tasks, coordinates    │
│  handoffs, keeps the rhythm.   │
│                                │
└────────────────────────────────┘
```

- Background: `--bg-card` with very subtle radial gradient using agent accent (opacity 0.06–0.08)
- Border: `1px solid --border`, hover → `--border-hover`
- Border-radius: `16px`
- Padding: `32px`
- Hover: card lifts `translateY(-2px)` + `box-shadow: 0 8px 32px rgba(0,0,0,0.3)`. Transition `0.3s ease`
- **Agent images:** Use 即梦-generated cyberpunk robot portraits from `shared/assets/squad-images/`
  - `admin-popo.png` → bronze commander
  - `thinker-kanye.png` → slate blue analyst
  - `gatekeeper-rocky.png` → sage green guardian
  - `creator-tyler.png` → mauve builder
- Image display: `200×200px`, `border-radius: 16px`, `object-fit: cover`
- Copy images to `public/images/agents/`

**Agent data:**

| Agent | Image | Name | Role | Description |
|---|---|---|---|---|
| Admin | 🎤 | Popo | Coordinator | Orchestrates the team. Assigns tasks, coordinates handoffs, keeps the rhythm. |
| Thinker | 🧠 | Kanye | Researcher | Goes deep on problems. Research, analysis, specs — the team's brain. |
| Gatekeeper | 🛡️ | Rocky | Reviewer | Quality control. Every deliverable passes through before shipping. |
| Creator | 🛠️ | Tyler | Builder | Turns specs into reality. Code, design, implementation. |

**Animation:** Cards fade in staggered (100ms delay each) on scroll into view.

### 5.4 Pull Quote

Full-width section. Large editorial quote, microsoft.ai style.

```
"Think it, build it, check it, ship it —
 squad never slippin'."
```

- Font: Playfair Display Italic, 36px desktop / 24px mobile
- Color: `--text-primary`
- Max-width: `800px`, centered
- Below quote: "— The Squad Motto" in Inter 400, 14px, `--text-muted`
- Generous vertical padding: `120px` top/bottom
- Optional: very subtle horizontal rule above and below (`--border`, 1px, max-width `120px`, centered)

**Animation:** Fade in on scroll. No theatrics.

### 5.5 Pipeline

**Heading:** "How We Work" — Playfair Display, 48px, centered

A clean horizontal flow showing the 4-step process. NOT scroll-driven. Just a static/simple diagram.

**Desktop layout:** Horizontal row of 4 connected steps
```
  [Think] ——→ [Build] ——→ [Check] ——→ [Ship]
   🧠           🛠️          🛡️          🎤
  Thinker     Creator    Gatekeeper    Admin
```

- Each step: a small card (160×160px) with emoji, step name, agent name
- Connection: thin line (`1px, --border`) with subtle arrow
- Step cards: `--bg-card`, `border-radius: 12px`, `padding: 24px`, centered text
- Active/hover: border brightens to `--border-hover`

**Mobile:** Vertical stack, arrows pointing down.

**Animation:** Steps appear one by one, left to right, with 150ms stagger on scroll. Connection lines draw in.

### 5.6 Terminal

A static code card showing what a task handoff looks like. NOT scroll-animated.

**Heading:** "Under the Hood" — Playfair Display, 48px, centered

```
┌──────────────────────────────────────────────────┐
│  task-handoff.md                          ── □ × │
├──────────────────────────────────────────────────┤
│                                                  │
│  # Task Handoff                                  │
│                                                  │
│  - From: Thinker 🧠                              │
│  - To: Creator 🛠️                                │
│  - Priority: urgent                              │
│                                                  │
│  ## Task                                         │
│  Build the landing page from v7 spec             │
│                                                  │
│  ## Context                                      │
│  Design reference: microsoft.ai                  │
│  Stack: Next.js 14 + Tailwind + Framer Motion    │
│                                                  │
└──────────────────────────────────────────────────┘
```

- Background: `#111111`
- Border: `1px solid --border`
- Border-radius: `12px`
- Font: JetBrains Mono, 14px
- Syntax highlighting: keywords in `--text-primary`, values in agent accent colors (muted)
- Title bar: fake window chrome with dots (optional, subtle)
- Max-width: `640px`, centered

**Animation:** Fade in on scroll. Optional: lines appear one by one with subtle typewriter delay (but NOT scroll-driven — use a simple `useInView` trigger).

### 5.7 CTA

Centered, minimal.

```
Ready to build your squad?

[Get Started →]
```

- Headline: Playfair Display, 40px, `--text-primary`
- Subtext: Inter 400, 16px, `--text-secondary` — "Open source. Self-hosted. Your agents, your rules."
- Button: `padding: 16px 32px`, `border-radius: 8px`, `background: #f5f5f5`, `color: #0a0a0a`, Inter 500, 15px
- Button hover: `background: #ffffff`, `translateY(-1px)`, subtle shadow
- No gradient borders, no glow — just a clean inverted button
- Vertical padding: `120px`

**Animation:** Fade in.

### 5.8 Footer

Minimal, single line or two-line.

```
SQUAD · Open Source · GitHub · Discord
© 2026
```

- Inter 400, 13px, `--text-muted`
- Links hover → `--text-secondary`
- Padding: `48px` vertical
- Border top: `1px solid --border`

---

## 6. Animation Spec

**Philosophy:** microsoft.ai uses almost no animation. What exists is invisible — things appear smoothly, nothing bounces or spins.

**Allowed animations:**

| Animation | Where | Spec |
|---|---|---|
| Fade in + slide up | All sections | `opacity: 0→1`, `translateY: 20px→0`, `duration: 0.6s`, `ease: [0.25, 0.1, 0.25, 1]` |
| Staggered fade | Agent cards, pipeline steps | Same as above, `staggerChildren: 0.1s` |
| Hover lift | Cards | `translateY: -2px`, `duration: 0.3s` |
| Border brighten | Cards on hover | `borderColor` transition, `0.2s` |
| Line draw | Pipeline connectors | `pathLength: 0→1`, `duration: 0.8s` (optional) |

**Banned animations:**
- ❌ Scroll-pinning / scroll hijacking
- ❌ GSAP ScrollTrigger
- ❌ Parallax (beyond very subtle background shift)
- ❌ 3D transforms / perspective
- ❌ Particle effects
- ❌ Bouncing / elastic easing
- ❌ Continuous looping animations
- ❌ Text scramble / typewriter on scroll

**Implementation:**
- Use Framer Motion's `useInView` or `whileInView` for scroll reveals
- `once: true` — animate in once, don't re-trigger
- `prefers-reduced-motion`: skip all motion, show final state immediately

---

## 7. Tech Stack

| Layer | Choice | Notes |
|---|---|---|
| Framework | Next.js 14 (App Router) | Static export OK |
| Styling | Tailwind CSS | Utility-first, dark mode default |
| Animation | Framer Motion | `whileInView` for scroll reveals only |
| Fonts | `next/font` | Playfair Display + Inter + JetBrains Mono |
| Deployment | Static / Cloudflare | Single page, no server needed |

**Dropped from v5/v6:**
- ~~Three.js / React Three Fiber~~ — no 3D
- ~~GSAP + ScrollTrigger~~ — no scroll-pinning
- ~~Lenis~~ — native scroll is fine
- ~~drei / postprocessing~~ — no WebGL

---

## 8. Performance Budget

| Metric | Target |
|---|---|
| First load JS | < 120KB gzipped |
| Total page weight | < 500KB |
| LCP | < 2.0s |
| CLS | < 0.05 |
| FID | < 100ms |
| Lighthouse perf | > 95 |

Fonts are the main weight. Three fonts × 1-2 weights each ≈ 150KB. Consider:
- Subset fonts to Latin only
- Use `font-display: swap`
- Preload display font

---

## 9. Responsive Breakpoints

| Breakpoint | Width | Changes |
|---|---|---|
| Mobile | < 640px | Single column, smaller type, stacked pipeline |
| Tablet | 640–1024px | 2-column agents, horizontal pipeline |
| Desktop | > 1024px | Full layout as specified |

---

## 10. Accessibility

- Semantic HTML: `<header>`, `<main>`, `<section>`, `<footer>`
- All sections have `aria-label`
- Color contrast: `--text-primary` on `--bg-primary` = 18:1 ✅, `--text-secondary` on `--bg-primary` = 7:1 ✅
- Focus visible states on all interactive elements
- `prefers-reduced-motion` respected
- Skip-to-content link
- No content hidden behind scroll animations

---

## Summary: v6 → v7 Changes

| Aspect | v6 | v7 |
|---|---|---|
| Hero | Three.js NeuralMesh, WebGL | Pure typography + subtle gradient |
| Scroll | GSAP ScrollTrigger pinning | Framer Motion `whileInView` |
| Style | Cyberpunk / tech-forward | Editorial luxury / magazine |
| Typography | Sans-serif only | Serif display + sans-serif body |
| Palette | Electric violet, neon accents | Muted earth tones, near-black |
| Animation | Complex, scroll-driven | Minimal fade-ins only |
| Dependencies | 8+ animation libs | Next.js + Tailwind + Framer Motion |
| Performance | ~300KB JS | Target <120KB JS |
| Reference | — | microsoft.ai |
