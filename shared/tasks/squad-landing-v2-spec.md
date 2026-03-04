# Squad Landing Page v2 — UI Spec

**Author:** Thinker 🧠
**Date:** 2026-02-25
**Status:** For review → Gatekeeper → Creator

---

## Problem with v1

The current build is *functional but tame*. It reads like a clean SaaS template, not like a squad of AI agents with personality. Specific issues:

1. **Hero is forgettable** — CSS particle dots + gradient background are generic. Every landing page has this.
2. **Emoji avatars feel like a prototype** — 👮🧠🛡️🛠️ are placeholders, not a visual identity.
3. **Low visual contrast** — everything blends into dark gray. Nothing punches.
4. **Animations are safe** — subtle fade-ups and floats. No "wow" moment.
5. **No visual storytelling** — the pipeline/workflow is explained in text, not shown dramatically.

---

## Reference Sites (Study These)

| # | Site | URL | What to steal |
|---|---|---|---|
| 1 | **Basement Studio** | https://basement.studio | 3D hero, bold typography, attitude in every pixel. "We make cool shit that performs." — that energy. |
| 2 | **Lusion** | https://lusion.co | WebGL scenes as hero backgrounds, immersive cursor interactions, depth-of-field effects. |
| 3 | **Linear** | https://linear.app | Dark mode perfection. Subtle gradient meshes, crisp type, feature sections with glowing cards. |
| 4 | **Vercel** | https://vercel.com | Gradient text, animated code blocks, the "beam" effect on cards, command palette aesthetics. |
| 5 | **Stripe** | https://stripe.com | Color gradients that feel alive, animated mesh backgrounds, layered card layouts. |
| 6 | **Raycast** | https://raycast.com | Keyboard-driven feel, glass-morphism cards, neon accents on dark backgrounds. |
| 7 | **Opal Camera** | https://opalcamera.com | Product hero that commands attention, cinematic scroll sequences, premium feel. |
| 8 | **KidSuper World** | https://kidsuper.world | Art-forward, breaks the grid, personality over polish. Creative energy. |

**Common patterns across all of these:**
- Hero sections that are *experiences*, not just text + background
- Bold, oversized typography (100px+ headings)
- Animated gradient meshes or WebGL backgrounds
- Cards with glow/border effects on hover
- Scroll-driven storytelling, not static sections

---

## V2 Visual Direction

### Overall Vibe
**"Cyberpunk command center meets hip-hop crew page."**

Think: dark, electric, bold. Each agent has a strong visual identity. The page should feel like a music group's website crossed with a tech studio portfolio. High contrast. Neon accents. Movement everywhere.

### Color Evolution

**Keep:** Dark base (#0A0A0A), the 4 accent colors (blue, purple, red, green) for agents.

**Add:**
- **Gradient mesh backgrounds** — animated multi-color mesh (purple ↔ blue ↔ dark) instead of simple linear gradients
- **Neon glow effects** — accent colors at full saturation for borders, text highlights, and card edges
- **Higher contrast** — white text at #FFFFFF for headings (not #F5F5F7), bolder accent usage
- **Glass/frosted surfaces** — `backdrop-filter: blur(16px)` + semi-transparent backgrounds for cards

### Typography Evolution

**Current:** Inter, conservative sizing.

**V2:**
- **Hero heading:** 120–160px, bold 800 weight, tight tracking (-0.04em). Consider **Space Grotesk** or **Clash Display** for headings (keep Inter for body).
- **Gradient text** on the hero headline — purple → blue → white sweep
- **Agent names:** 32px+ bold, each in their accent color
- **Subheadings:** All-caps, wide letter-spacing (0.1em), smaller size — like a HUD label

---

## Section-by-Section Spec

### 1. Hero — "The Entrance"

**Goal:** Stop the scroll. Make someone say "whoa."

**Background:**
- **Option A (Recommended): ReactBits Aurora + Threads combo** — Use the `Aurora` background component for the animated color wash, layered with `Threads` or `Hyperspeed` for motion lines. These are from ReactBits and Creator already has the skill.
- **Option B: Animated gradient mesh** — CSS/canvas-based mesh gradient animation with 4 agent colors morphing. Like Stripe's hero background.
- **Option C: Three.js particle field** — Thousands of particles forming a subtle brain/network shape, responding to mouse position. Higher effort but highest wow.

**Content:**
- **Headline:** "Four Agents. One Machine. Zero Chill." — 140px, gradient text (purple→cyan→white), SplitText reveal animation from ReactBits
- **Subtitle:** Same text, but animate in word-by-word with blur-to-sharp effect
- **CTA:** Glowing pill button with animated border (gradient rotating border — ReactBits has this)
- **Floating elements:** Small holographic badges floating around the hero: "24/7 ONLINE", "THINKING...", "SHIPPING", "REVIEWING" — each in an agent's color, gently bobbing

**Animation timeline:**
1. Background fades in (0-0.3s)
2. Headline splits in from bottom, letter by letter (0.3-1.0s)
3. Subtitle blurs in (1.0-1.4s)
4. CTA slides up (1.4-1.7s)
5. Floating badges fade in staggered (1.7-2.5s)

---

### 2. Agent Cards — "Meet the Squad"

**Goal:** Each agent feels like a character, not a database entry.

**Avatar Strategy (CRITICAL CHANGE):**

Replace emojis with **illustrated avatars**. Three options:

- **Option A (Recommended): Abstract geometric avatars** — Each agent gets a unique geometric shape/pattern in their accent color. Think: Admin = shield/star shape, Thinker = brain/nebula, Gatekeeper = hexagonal lock pattern, Creator = exploding prism. These can be SVG-based and animated. No external dependencies.
- **Option B: AI-generated character illustrations** — Use a consistent art style (e.g., flat vector, cyberpunk portraits). Generate with Midjourney/DALL-E in a unified style. Save as static images. Fast to implement but needs generation step.
- **Option C: 3D renders** — Simple 3D objects (React Three Fiber) that rotate on hover. Brain, shield, hammer, crown. Highest wow, highest effort.

**Card Design:**
- **Larger cards** — Full width on mobile, 2-column grid on desktop (not 4-col — give them room to breathe)
- **Glassmorphism** — `backdrop-blur(16px)`, semi-transparent bg, subtle border glow in agent's color
- **Hover effect:** Card lifts + border illuminates + avatar animates (scales up, rotates, or pulses)
- **Background per card:** Subtle radial gradient in the agent's color, fading to transparent
- **Quote styling:** Large pull-quote style, italic, with accent-colored quotation marks
- **Animated entrance:** Cards slide in from alternating sides (left, right, left, right) on scroll — GSAP ScrollTrigger or Framer Motion `whileInView`

**Card content (enhanced):**
```
[Animated Avatar — SVG/geometric, in accent color]
[Name — 28px bold, accent color]
[Role — 14px caps, muted]
[Divider — animated gradient line]
[Description — 16px, white]
[Quote — 18px italic, accent color quotes]
[Tags — pill badges with subtle glow]
[Status indicator — pulsing dot + "Online" or "Thinking..."]
```

---

### 3. Pipeline Flow — "How We Ship"

**Goal:** Show the workflow as an animated, visual journey — not a static diagram.

**Design:**
- **Horizontal scroll section** (on desktop) or vertical timeline (mobile)
- **Connected nodes:** Each step is a glowing node connected by animated beam lines (like data flowing through a circuit)
- **Steps:**
  1. 🎤 Admin receives task → node pulses blue
  2. 🧠 Thinker researches → node pulses purple, "data streams" flow in
  3. 🛠️ Creator builds → node pulses green, code snippets animate
  4. 🛡️ Gatekeeper reviews → node pulses red, checkmark appears
  5. ✅ Shipped → all nodes light up simultaneously
- **Animation:** As user scrolls, each step activates sequentially. Lines animate between nodes. Use GSAP ScrollTrigger for precise scroll-driven control.
- **Background:** Dark with subtle grid pattern (like a circuit board / HUD)

---

### 4. Bento Grid — "What We Do"

**Goal:** Showcase capabilities in a visually rich grid.

**Design changes:**
- **Larger bento tiles** — Some 2x size, asymmetric layout (not uniform grid)
- **Each tile has a mini-animation or illustration** inside it, not just text + icon
- **Tile ideas:**
  - "24/7 Operation" — animated clock with glowing hands
  - "Code → Review → Ship" — animated terminal with typing effect
  - "Multi-Agent Collab" — 4 dots connecting/orbiting each other
  - "Slack-Native" — mock Slack message thread animating
  - "Self-Improving" — brain icon with expanding neural connections
- **Hover:** Tile scales slightly (1.02), border glows, internal animation speeds up
- **Glass effect** on tiles — consistent with card treatment

---

### 5. Terminal — "Live Demo Feel"

**Goal:** Show the squad in action with a realistic terminal.

**Enhancements:**
- **Full-width terminal** with macOS-style window chrome (traffic light dots)
- **Multi-tab terminal** — tabs labeled "Admin", "Thinker", "Creator", "Gatekeeper", each in their accent color
- **Animated typing** — simulate a real task flowing through the pipeline:
  ```
  [Admin] 📥 New task: Design squad landing page
  [Admin] 📤 HANDOFF → Thinker: Research + spec needed
  [Thinker] 📥 PICKUP: Research + spec (from Admin)
  [Thinker] ⏳ Researching 8 reference sites...
  [Thinker] ✅ DONE: Spec complete, 13K words
  [Thinker] 📤 HANDOFF → Creator: Build from spec
  [Creator] 📥 PICKUP: Building (from Thinker)
  [Creator] ⏳ Next.js + Tailwind + Framer Motion...
  [Creator] ✅ DONE: Build complete
  [Gatekeeper] 🔍 REVIEW: Checking code quality...
  [Gatekeeper] ✅ APPROVED: Ship it! 🚀
  ```
- Each line types in with the agent's accent color for the name/emoji
- Cursor blinks between lines
- The whole sequence loops

---

### 6. CTA — "Join / Follow / Star"

**Design:**
- **Full-width gradient section** — animated mesh gradient (purple→blue→dark)
- **Massive heading:** "Built Different." — 100px+, gradient text
- **Subtitle:** "Four agents. One VM. Always shipping."
- **Two CTAs:**
  - "Star on GitHub" → outlined button with hover fill
  - "Join the Discord" → solid accent button with glow
- **Background particles** — subtle, matching hero treatment for visual bookending

---

### 7. Footer

**Minimal but branded:**
- Dark bg, single line: "Think it, build it, check it, ship it — squad never slippin'" (the team motto)
- Links: GitHub, Discord, OpenClaw
- Small: "Running on OpenClaw. Always online."

---

## Animation Library Recommendations

| Purpose | Library | Why |
|---|---|---|
| Component animations, entrance/exit | **Framer Motion** | Already in v1, great API, handles layout animations |
| Scroll-driven sequences (pipeline) | **GSAP ScrollTrigger** | Gold standard for scroll animation. Creator has the gsap-react skill. |
| Hero background effects | **ReactBits** (Aurora, Threads, Hyperspeed) | Pre-built, performant, Creator has the skill |
| Text animations | **ReactBits** (SplitText, GradientText, BlurText) | Already partially used in v1, expand usage |
| 3D avatars (if Option C) | **React Three Fiber** | Creator has threejs skills. Only if we go 3D route. |
| Animated borders/buttons | **ReactBits** or CSS | Rotating gradient borders, glow effects |

**Recommendation:** Stick with **Framer Motion + GSAP + ReactBits**. This combo covers everything without needing Three.js (unless we want 3D avatars). Creator already has skills for all three.

---

## Image / Illustration Strategy

### Agent Avatars (Priority)
**Recommended approach: SVG geometric art**

Each agent gets a unique abstract SVG illustration:

- **Admin (Popo) 👮** — Accent: Blue — A command star / radar pulse shape. Concentric circles with a central point, like a mission control signal.
- **Thinker (Kanye) 🧠** — Accent: Purple — A nebula / neural cluster. Organic swirling shape with interconnected nodes.
- **Creator (Tyler) 🛠️** — Accent: Green — An exploding prism / building blocks. Geometric shards assembling into form.
- **Gatekeeper (Rocky) 🛡️** — Accent: Red — A hexagonal shield matrix. Interlocking hexagons forming a protective pattern.

These should be:
- ~200x200px SVGs, inline for animation control
- Animated: subtle rotation, pulse, or morph on idle; stronger effect on hover
- Consistent style: geometric, abstract, no faces, no realistic elements
- Creator can build these as React components with Framer Motion/CSS animations

### Other Illustrations
- **No stock photos.** Everything should be geometric, abstract, or code-based.
- **Grid/circuit patterns** as section backgrounds (SVG, tileable)
- **Gradient orbs** as decorative elements (CSS radial gradients, blurred, positioned absolute)

---

## Technical Notes for Creator

1. **Keep Next.js 14 + Tailwind + Framer Motion** base — no framework changes
2. **Add GSAP** via `npm install gsap` — use Creator's `gsap-react` skill for proper React integration (useGSAP hook, cleanup patterns)
3. **ReactBits components** — install from https://reactbits.dev, use the following:
   - `Aurora` or `Threads` for hero background
   - `SplitText` (already have), `GradientText`, `BlurText` for text effects
   - Animated border/button components if available
4. **Font change:** Add `Space Grotesk` or `Clash Display` via `next/font/google` for headings. Keep Inter for body.
5. **SVG avatars:** Build as individual React components in `components/avatars/`. Each exports an animated SVG.
6. **Responsive:** Mobile-first. Pipeline goes vertical on mobile. Cards go single-column.
7. **Performance:** Lazy-load below-fold sections. Use `will-change` sparingly. Respect `prefers-reduced-motion`.
8. **The vibe is BOLD.** When in doubt, make it bigger, brighter, more animated. This isn't a SaaS template — it's a crew page.

---

## Summary of Changes from v1

| Aspect | v1 | v2 |
|---|---|---|
| Hero bg | CSS gradient + tiny particles | ReactBits Aurora/Threads + gradient mesh |
| Hero text | 4.5rem, white | 8-10rem, gradient text, split animation |
| Avatars | Emoji (👮🧠🛡️🛠️) | Animated SVG geometric illustrations |
| Cards | 4-col, subtle hover | 2-col, glassmorphism, dramatic hover + glow |
| Pipeline | Static steps | Scroll-driven animated circuit/beam flow |
| Terminal | Basic typing | Multi-tab, full pipeline simulation, colored |
| Typography | Inter only, conservative | Space Grotesk headings + Inter body, bold sizes |
| Animations | Framer Motion only | Framer Motion + GSAP ScrollTrigger + ReactBits |
| Overall feel | Clean SaaS template | Cyberpunk command center / crew showcase |

---

*"Not fancy enough? Say less."* 🧠
