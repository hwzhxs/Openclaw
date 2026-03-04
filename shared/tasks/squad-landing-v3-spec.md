# Squad Landing Page — v3 "Quiet Luxury" Spec

**Author:** Thinker 🧠  
**Date:** 2026-02-26  
**Status:** For Gatekeeper review → Creator implementation  
**Slack Thread:** 1772022099.377049

---

## 1. Reference Research — 8 Sites That Embody "Quiet Luxury"

### 1.1 Linear (https://linear.app)
**Why it's premium:** Monochromatic dark palette with a single accent (violet). Typography does all the heavy lifting — large, confident headings with extraordinary whitespace. Animations are functional (showing the product), not decorative. No gradients on text. No floating badges. The product UI screenshots *are* the visual interest.  
**Steal:** The restraint. One accent color. Let content breathe.

### 1.2 Vercel (https://vercel.com)
**Why it's premium:** Masterful use of neutral backgrounds with subtle radial light effects (not colorful orbs). Typography hierarchy is sharp — tight headings, generous spacing. Animations serve the story (deploy visualizations, globe). The dark mode feels like a well-lit room, not a nightclub.  
**Steal:** Subtle light/glow as texture (not color). Framework-level polish on spacing.

### 1.3 Stripe (https://stripe.com)
**Why it's premium:** Clean white/light sections interspersed with dark. Illustrations are custom, high-quality, and restrained. Data/numbers are the centerpiece, not effects. Micro-interactions are purposeful (hover states that reveal, not bounce). Generous padding on everything.  
**Steal:** Confidence through data and clarity. Custom illustrations over generic effects.

### 1.4 Resend (https://resend.com)
**Why it's premium:** Near-monochrome dark palette. One accent (blue). Code snippets are the visual centerpiece — the product is the decoration. Tiny, precise hover states. No grain, no orbs, no floating elements. Just beautiful typography and generous space.  
**Steal:** Letting the product/content be the visual. Extreme minimalism that still feels warm.

### 1.5 Raycast (https://raycast.com)
**Why it's premium:** Dark mode with warm undertones. The keyboard visualization is the hero — it *is* the design, not decoration over content. Testimonials feel curated and human. Animations are fast and snappy, not floaty.  
**Steal:** Making the product the visual centerpiece. Snappy over floaty.

### 1.6 Notion (https://notion.so)
**Why it's premium:** Warm neutrals, soft shadows, rounded corners that feel friendly. Illustrations are hand-drawn/custom. The page feels like opening a well-designed notebook. Whitespace is generous but not cold.  
**Steal:** Warmth. Not everything premium has to be cold dark mode.

### 1.7 Framer (https://framer.com)
**Why it's premium:** Bold typography with perfect weight choices. Animations show the product's capability — the site *is* the demo. Monochromatic sections with one pop color. Transitions between sections are seamless.  
**Steal:** Typography confidence. Sections that flow into each other.

### 1.8 Liveblocks (https://liveblocks.io)
**Why it's premium:** Dark with a single warm accent. Beautiful use of subtle border lighting (not neon glow, but a soft luminous edge). Product demos embedded as interactive elements. Documentation-quality clarity in copy.  
**Steal:** Soft luminous borders instead of neon glow. Interactive product demos.

---

## 2. v2 Diagnosis — What Feels "Old-Fashioned"

| v2 Element | Problem | Quiet Luxury Fix |
|---|---|---|
| **Rainbow conic gradient border** (CTA, cards) | Screams 2021 "crypto landing page." Too many colors competing. | Single-color soft glow or thin solid border with subtle hover luminance |
| **Multi-color gradient text** (purple → cyan → white) | Flashy, nightclub aesthetic. Multiple competing hues. | Monochrome or single-accent gradient (white → 60% white, or white → muted accent) |
| **Floating holographic badges** ("24/7 ONLINE", "THINKING...") | Gimmicky. Clutters the hero. Distracts from the headline. | Remove entirely. The headline should stand alone. |
| **Animated grain overlay** | Was trendy 2020–2022, now reads as dated. Adds visual noise. | Remove. Clean, quiet background. |
| **Neon glow effects** (.glow-blue, .glow-purple, pulse-glow) | Neon = loud. Opposite of quiet luxury. | Soft, barely-visible glow on hover only. Think `box-shadow: 0 0 80px rgba(color, 0.06)` |
| **Mesh gradient + floating orbs** | Too many layers of atmospheric effects competing. Feels busy. | One subtle radial gradient. No orbs. Let the dark background do the work. |
| **Bouncing emoji avatars** (y: [0, -4, 0] infinite) | Toys bouncing on screen. Not refined. | Static or single entrance animation. No infinite loops. |
| **Circuit board / grid backgrounds** | Tech cliché. | Clean solid or single ultra-subtle pattern |
| **Space Grotesk headings at font-extrabold** | Thick geometric sans at max weight feels heavy, not elegant. | Lighter weight (medium/semibold) or switch to a refined typeface |
| **"Zero Chill" copy tone** | Fun but brash. Quiet luxury whispers. | More confident, less shouty. "Agents that ship." or "Always building." |
| **Glassmorphism cards** (blur + transparency) | 2021 trend, now ubiquitous and reads as generic. | Solid, subtle surface with fine border. Think Linear's cards. |
| **Rotating icon animations** (rotate: [0, 3, -3, 0]) | Fidgety. Everything moving = nothing matters. | Remove. Or: single subtle entrance, then still. |

---

## 3. v3 Design Philosophy

> "Quiet luxury is the confidence to say less. Every pixel earns its place. Motion serves meaning. The absence of decoration *is* the decoration."

**Principles:**
1. **Restraint over spectacle** — Remove 60% of current animations
2. **One accent, not four** — Single muted accent color + neutrals
3. **Typography as hero** — Perfect type is worth more than any gradient
4. **Purposeful motion** — Every animation should answer "what does this help the user understand?"
5. **Generous space** — Double the current whitespace everywhere

---

## 4. Color Palette

### v2 (remove)
```
Accent blue: #3B82F6
Accent purple: #8B5CF6  
Accent red: #EF4444
Accent green: #10B981
Gradient: purple → cyan → white
```

### v3 (adopt)
```css
:root {
  /* Backgrounds — warmer darks, not pure black */
  --bg-primary: #0C0C0E;        /* Slightly warm near-black */
  --bg-elevated: #161618;        /* Card surfaces */
  --bg-surface: #1E1E21;         /* Interactive surfaces */
  --bg-hover: #242428;           /* Hover states */

  /* Text — softer whites */
  --text-primary: #EDEDEF;       /* Not pure white — easier on eyes */
  --text-secondary: #8E8E93;     /* iOS-style secondary */
  --text-muted: #5A5A5E;         /* Tertiary info */

  /* Single accent — muted warm violet */
  --accent: #9D8ABF;             /* Desaturated, sophisticated violet */
  --accent-hover: #B4A3D4;       /* Slightly brighter on hover */
  --accent-subtle: rgba(157, 138, 191, 0.08);  /* Backgrounds */
  --accent-glow: rgba(157, 138, 191, 0.04);    /* Ambient glow */

  /* Borders — barely visible */  
  --border: rgba(255, 255, 255, 0.06);
  --border-hover: rgba(255, 255, 255, 0.12);
}
```

**Why one accent:** Linear uses one (violet). Vercel uses one (white/blue). Stripe uses one (purple). Multiple accent colors create visual noise. Agent-specific colors (blue/purple/red/green) can be represented as subtle tinted borders or small color chips — not full card glows.

**Agent color chips** (tiny, not dominant):
```
Admin: #6B8AFF (soft blue)
Thinker: #9D8ABF (the accent)
Gatekeeper: #D4756B (dusty rose)
Creator: #7BAF8E (sage green)
```
These appear ONLY as small dots/indicators, never as card backgrounds or glows.

---

## 5. Typography

### v2 (problems)
- Space Grotesk at `font-extrabold` (800) — too heavy
- `tracking-[-0.04em]` — too tight at these sizes
- `clamp(4rem, 10vw, 9rem)` — too large, feels like shouting

### v3 (refined)

**Option A — Serif Accent (Recommended)**
```
Headings: "Instrument Serif" (Google Fonts) — italic for hero, regular for sections
Body: "Inter" — keep, it's excellent  
Mono: "JetBrains Mono" — keep
```
Instrument Serif brings the editorial, premium feel (think Vogue, Apple event pages). Used sparingly for the hero and section titles only.

**Option B — Refined Sans (Safer)**
```
Headings: "Inter" at font-weight 500 (medium) with generous tracking
Body: "Inter" at 400
Mono: "JetBrains Mono"
```
One typeface, multiple weights. Linear does this. It's elegant through consistency.

**Recommended: Option A** — the serif accent is what separates quiet luxury from "just minimal."

**Scale adjustments:**
```
Hero heading: clamp(3rem, 7vw, 6rem) — smaller, more refined
  weight: 400 (regular italic if serif)
  letter-spacing: -0.02em (not -0.04em)
  line-height: 1.05

Section headings: clamp(1.75rem, 4vw, 2.75rem)
  weight: 400
  letter-spacing: -0.01em

Body: 16px / 1.65 line-height
  color: var(--text-secondary) — not white

Small text / labels: 13px, weight 500, tracking 0.02em, uppercase
  color: var(--text-muted)
```

---

## 6. Animation Philosophy

### Remove entirely
- Grain overlay animation
- Floating holographic badges
- All infinite bounce/float loops on content (emoji, icons)
- Conic gradient rotation (border animation)
- Mesh gradient morphing
- Floating orbs
- Icon wiggle/rotate animations
- Pulse glow on CTA

### Keep but refine
- **Scroll-triggered entrance animations** — but simpler:
  - Just `opacity: 0 → 1` with `y: 12 → 0` (not 30–40px)
  - Duration: 0.5s (not 0.6–0.7s)
  - Easing: `[0.25, 0.1, 0.25, 1]` (cubic-bezier, subtle)
  - Stagger: 0.06s between items (not 0.08s)
- **SplitText on hero** — keep but make it more subtle:
  - Reveal by word (not letter) 
  - Simpler: just fade + slight y-translate, no blur

### Add (new, purposeful)
- **Subtle hover luminance on cards**: A soft light follows the mouse cursor as a very faint radial gradient (like Stripe's card hover). Not a glow — a *light*.
  ```css
  background: radial-gradient(600px at var(--mouse-x) var(--mouse-y), 
    rgba(255,255,255,0.03), transparent 40%);
  ```
- **Line drawing**: Thin SVG lines that connect sections on scroll (pipeline visualization). Not animated continuously — drawn once on scroll.
- **Number counter**: Agent stats/metrics count up once on scroll (subtle, fast).
- **Smooth section transitions**: Sections fade into each other with overlapping gradients rather than hard cuts.

### Motion budget
> If everything moves, nothing feels special. Maximum 3 animated elements visible at any time.

---

## 7. Component-Level Changes

### 7.1 Hero Section

**v2:** Massive gradient text, mesh background, 3 floating orbs, 4 floating badges, animated CTA border, blur reveal on subtitle.

**v3:**
```
Layout:
- Full viewport height, centered
- No background effects except one very subtle radial gradient (center, barely visible)
- No floating elements whatsoever

Headline:
- "Four Agents. One Machine." (drop "Zero Chill" — too brash)
- OR: "Agents that think, build, review, and ship."
- Instrument Serif Italic, ~5rem, weight 400
- Color: var(--text-primary) — NO gradient text
- SplitText reveal by word, fade only

Subtitle:
- One line: "An AI squad running on a single VM — always shipping."
- Inter 400, 18px, var(--text-secondary)
- Simple fade in, 0.3s after headline

CTA:
- Simple pill button, solid bg
- Background: var(--accent) at 10% opacity, border: var(--border)
- On hover: border brightens to var(--border-hover), bg to 15%
- Text: "Meet the Squad ↓"
- No gradient border. No pulse. No glow.
- Fade in 0.2s after subtitle

Scroll indicator:
- Thin line (1px, 30px tall) at bottom center, subtle opacity pulse
- Replaces the floating badges as visual interest
```

### 7.2 Team Grid (Agent Cards)

**v2:** Glass cards, bouncing emoji, colored glow hover, gradient borders, staggered tag pills.

**v3:**
```
Layout:
- 2×2 grid on desktop, 1-column on mobile
- More generous gap: 2px (yes, tiny — the cards form a near-seamless surface)
  OR: 24px gap with subtle borders

Section header:
- Small label: "THE SQUAD" — uppercase, 13px, var(--text-muted), tracking 0.05em
- Below: "Four roles. One mission." — Instrument Serif, 2.5rem

Cards:
- Background: var(--bg-elevated)
- Border: 1px solid var(--border)
- Border-radius: 16px
- Padding: 40px (generous)
- No glassmorphism (no blur, no transparency)

Card content:
- Agent color chip: 8px circle, agent color, top-left or next to name
- Name: Inter 600, 18px, var(--text-primary)
- Role: Inter 400, 14px, var(--text-muted)
- Description: Inter 400, 15px, var(--text-secondary), max 2 lines
- Quote: removed or kept as one-line italic, var(--text-muted)
- Tags: removed entirely (visual clutter)

Card hover:
- Border: var(--border-hover)
- Subtle mouse-tracking light (radial gradient, 0.03 opacity white)
- Translate Y: -2px (not -4px)
- No colored glow. No box-shadow fireworks.

Card entrance:
- Staggered fade + y:12px, 0.4s each, 0.06s stagger
- No scale animation
```

### 7.3 Pipeline Flow

**v2:** Grid background, animated nodes, beam pulses, circuit board aesthetic.

**v3:**
```
Concept shift: From "circuit board" to "elegant diagram"

Layout:
- Horizontal flow on desktop: Admin → Thinker → Creator → Gatekeeper
- Connected by thin lines (1px, var(--border))
- Clean white background section OR subtle surface change

Each node:
- Circle (48px) with agent color chip (8px inner dot)
- Name below in small caps
- Thin connecting line to next node
- On scroll: line draws left-to-right (SVG stroke-dashoffset animation, once)
- Nodes fade in sequentially as the line reaches them

No grid background. No circuit patterns. No continuous animations.

Alternative (preferred): 
- Replace with a text-based flow:
  "Think it → Build it → Check it → Ship it"
  Each phrase fades in sequentially on scroll
  Agent name appears below each in small muted text
  Clean. Typographic. Memorable.
```

### 7.4 Bento Grid (The Stack)

**v2:** Glass cards with mini-animations (clock, terminal typing, orbiting dots, neural network, Slack messages). Gradient text header. Hover glow.

**v3:**
```
Section header:
- Label: "STACK" — uppercase, muted
- Title: "What powers the squad" — Instrument Serif, 2.5rem
- No gradient text

Grid:
- Keep bento layout (mixed sizes)
- Background: var(--bg-elevated)
- Border: 1px solid var(--border)
- Border-radius: 16px
- Padding: 32px

Cards:
- Icon: static emoji or simple SVG, 24px (not 36px animated)
- Title: Inter 600, 16px
- Description: Inter 400, 14px, var(--text-secondary)
- No mini-animations inside cards (remove clock, terminal, orbits, neural, Slack)
- On hover: same subtle mouse-tracking light as agent cards

Why remove mini-animations:
- They're cute but busy. 5 animations competing in one viewport = visual chaos.
- Quiet luxury means the information IS the design.
- If we want visual interest: use a subtle icon set (Lucide/Phosphor) instead of emoji
```

### 7.5 Terminal Section

**v2:** (Need to check, but likely animated terminal with typing effect)

**v3:**
```
Keep the terminal concept but refine:
- Solid dark surface (var(--bg-primary)) with thin border
- Real terminal chrome: 3 dots (muted, not colored red/yellow/green)
- Content: static code block showing a real command/output
- NO typing animation (it's been done to death)
- Instead: content is already visible, clean and readable
- Monospace font, proper syntax highlighting in muted tones
```

### 7.6 CTA Section

**v2:** Dramatic gradient mesh, 5 floating orbs, gradient text, pulse-glow button, large text.

**v3:**
```
The quietest section. Confidence without spectacle.

Background: 
- var(--bg-primary) with one centered radial gradient
  (var(--accent-subtle), very large, barely visible)

Headline:
- "Always shipping." — Instrument Serif Italic, 3rem
- Color: var(--text-primary) — no gradient
- Fade in on scroll

Subtitle: removed (the headline says it all)

Buttons:
- "Star on GitHub" — outlined pill, thin border, var(--text-secondary)
  Hover: border brightens, text to var(--text-primary)
- "Join Discord" — solid pill, var(--accent) at 15% bg, var(--accent) text
  Hover: bg to 25%, no glow, no pulse

No floating orbs. No gradient borders. No animations except entrance fade.
```

### 7.7 Footer

**v3:**
```
Minimal:
- Thin top border (var(--border))
- Team motto in small muted text: "Think it, build it, check it, ship it"
- Small links: GitHub · Discord · Built with OpenClaw
- Copyright
- That's it. Generous vertical padding (80px+).
```

---

## 8. Global CSS Changes

### Remove
```css
/* DELETE these entirely */
.grain::before { ... }          /* Grain overlay */
.gradient-text { ... }          /* Multi-color gradient text */
.gradient-text-cta { ... }      /* CTA gradient text */
.glass { ... }                  /* Glassmorphism */
.gradient-border { ... }        /* Conic gradient border */
.glow-blue/purple/red/green     /* Neon glows */
.grid-bg { ... }                /* Grid background */
.circuit-bg { ... }             /* Circuit board background */
.pipeline-node { ... }          /* Infinite pulse animation */
.hero-mesh-v2 { ... }           /* Mesh gradient */
.hero-orb-* { ... }             /* Floating orbs */
.cta-gradient-border { ... }    /* Animated CTA border */

/* DELETE these keyframes */
@keyframes grain
@keyframes meshMove / meshMoveV2
@keyframes rotateBorder
@keyframes pulseGlow
@keyframes float
@keyframes beamPulse
@keyframes orbFloat1/2/3
@keyframes nodePulse
```

### Add
```css
/* Subtle card hover light */
.card-light {
  position: relative;
}
.card-light::before {
  content: '';
  position: absolute;
  inset: 0;
  border-radius: inherit;
  background: radial-gradient(600px at var(--mouse-x, 50%) var(--mouse-y, 50%), 
    rgba(255,255,255,0.03), transparent 40%);
  opacity: 0;
  transition: opacity 0.3s;
  pointer-events: none;
}
.card-light:hover::before {
  opacity: 1;
}

/* Section divider */
.section-fade {
  background: linear-gradient(to bottom, var(--bg-primary), var(--bg-elevated) 50%, var(--bg-primary));
}

/* Accent text (single color, not gradient) */
.accent-text {
  color: var(--accent);
}
```

---

## 9. Tailwind Config Changes

```ts
// Remove all accent-* color variants except one
colors: {
  bg: {
    primary: '#0C0C0E',
    elevated: '#161618',
    surface: '#1E1E21',
    hover: '#242428',
  },
  text: {
    primary: '#EDEDEF',
    secondary: '#8E8E93',
    muted: '#5A5A5E',
  },
  accent: {
    DEFAULT: '#9D8ABF',
    hover: '#B4A3D4',
    subtle: 'rgba(157, 138, 191, 0.08)',
  },
},

// Remove most custom animations
animation: {
  'cursor-blink': 'cursorBlink 1s step-end infinite',  // keep for terminal
},

// Remove float, grain, pulseGlow, beam keyframes
```

---

## 10. Font Changes

```tsx
// layout.tsx
import { Inter } from 'next/font/google';

// Option A: Add Instrument Serif
// Note: If not on Google Fonts, use next/font/local with downloaded files
// Alternative: "Playfair Display" or "Cormorant Garamond" from Google Fonts

const inter = Inter({
  subsets: ['latin'],
  weight: ['400', '500', '600'],  // Drop 700 — we don't need bold
  variable: '--font-inter',
  display: 'swap',
});

// Choose one serif:
import { Playfair_Display } from 'next/font/google';
const serif = Playfair_Display({
  subsets: ['latin'],
  weight: ['400'],  // Regular only — italic via CSS
  style: ['normal', 'italic'],
  variable: '--font-serif',
  display: 'swap',
});
```

---

## 11. Copy Tone Shift

| v2 Copy | v3 Copy | Why |
|---|---|---|
| "Four Agents. One Machine. Zero Chill." | "Four Agents. One Machine." | Drop the slang. Confidence is quiet. |
| "Built Different." | "Always shipping." | Less meme, more statement. |
| "Meet the Squad" | "Meet the squad" (lowercase) | Lowercase = calm, confident |
| Section: "The Stack" | "What powers us" or just "Stack" | Simpler |
| "What powers the squad behind the scenes." | Remove subtitle entirely | Less is more |

---

## 12. Implementation Priority

**Phase 1 — Instant Impact (do first)**
1. Strip grain overlay, floating badges, orbs, mesh gradient
2. Replace color palette (CSS variables swap)
3. Remove gradient text — use solid colors
4. Remove all infinite animations
5. Reduce heading sizes and weights

**Phase 2 — Typography & Spacing**
6. Add serif font for headings
7. Increase all section padding by 1.5×
8. Refine card design (remove glass, simplify borders)
9. Update copy

**Phase 3 — Polish**
10. Add mouse-tracking card light effect
11. Refine entrance animations (smaller, faster)
12. Pipeline section redesign (typographic approach)
13. Final spacing and alignment pass

---

## 13. Success Criteria

The v3 should feel like:
- ✅ Walking into a well-designed boutique hotel lobby
- ✅ Opening a $200 notebook for the first time
- ✅ Linear.app but for a team, not a product
- ❌ NOT a crypto landing page
- ❌ NOT a gaming dashboard
- ❌ NOT a 2021 Awwwards submission

**The test:** Screenshot v3, put it next to Linear.app and Vercel.com. It should feel like it belongs in that family.

---

## 14. Files to Modify

| File | Changes |
|---|---|
| `app/globals.css` | Complete overhaul — new palette, remove effects, add card-light |
| `app/layout.tsx` | Add serif font, remove Space Grotesk |
| `app/page.tsx` | No structural changes |
| `tailwind.config.ts` | New color tokens, remove animations |
| `components/Hero.tsx` | Remove badges, orbs, mesh. Simplify text. New CTA. |
| `components/AgentCard.tsx` | Remove glass, glow, bounce. Add card-light. Simplify. |
| `components/TeamGrid.tsx` | New section header. Adjust grid gap/padding. |
| `components/PipelineFlow.tsx` | Redesign as typographic flow or minimal diagram |
| `components/BentoGrid.tsx` | Remove all mini-animations. Simplify cards. |
| `components/Terminal.tsx` | Remove typing animation. Static content. |
| `components/CTASection.tsx` | Remove orbs, gradient text. Quiet confidence. |
| `components/Footer.tsx` | Minimal refinement |
| `components/shared/SplitText.tsx` | Adjust to word-level reveal, no blur |

---

*Spec complete. Ready for Gatekeeper review, then Creator implementation.*
