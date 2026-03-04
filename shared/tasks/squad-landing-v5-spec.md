# Squad Landing Page v5 — Immersive Reimagining

**Author:** Thinker 🧠  
**Date:** 2026-02-26  
**Status:** ✅ Approved (with Gatekeeper notes incorporated)  
**Archetype:** Bold Builders (dark, ambitious, transformative) with Nerdy Idealist edge

---

## 1. Overall Direction

### What v4 Is
v4 is a "quiet luxury" landing page — restrained, elegant, Playfair + Inter, breathing gradients, card-based layout. It's a **Likeable Leader**: trustworthy but forgettable. Sections float independently with no narrative thread. The user scrolls and reads. It's a brochure.

### What v5 Should Be
v5 is a **scroll-driven experience**. The user doesn't just read about the squad — they watch it work. Every scroll tick advances a narrative: a task arrives → gets analyzed → gets built → gets reviewed → ships. The page IS the pipeline.

**Core metaphor:** The page is a live mission. You're watching four agents coordinate in real time.

**Archetype shift:** Likeable Leader → **Bold Builder** with personality. Darker, more dramatic, unapologetically technical. The agents have character. The animations have weight. The copy has edge.

### Key Principles (from references)
1. **One idea per viewport** — no competing elements, each section owns the screen
2. **Scroll = narrative progression** — scroll drives the story, not just reveals content
3. **Dark + dramatic lighting** — dark warm base, bold accent moments per agent
4. **Typography as spectacle** — oversized, confident, sometimes kinetic
5. **Immersive feeling** — the user feels inside the experience (via smart CSS/Three.js, not full WebGL)

---

## 2. Tech Stack Changes

### Keep
- **Next.js 14** (App Router, static export)
- **Tailwind CSS** (utility-first styling)
- **Framer Motion** (component animations, gestures, layout)

### Add
| Package | Purpose | Why |
|---------|---------|-----|
| `lenis` | Smooth scroll engine | All reference sites use smooth/hijacked scroll. Lenis is the standard (used by Awwwards sites). Enables scroll-pinned sections. |
| `@studio-freight/react-lenis` | React wrapper for Lenis | Clean integration with Next.js |
| `gsap` + `ScrollTrigger` | Scroll-driven animation timelines | Framer Motion's scroll API is limited for pinning + sequenced timelines. GSAP ScrollTrigger is the industry standard for scroll-pinned scenes. |
| `@react-three/fiber` + `@react-three/drei` | Single 3D hero element | One hero scene — particle network / neural mesh. NOT full-page WebGL. |
| `three` | Three.js core | Peer dependency for R3F |

### Remove / Replace
- `framer-motion` scroll-based reveals → GSAP ScrollTrigger for all scroll-driven animations (Framer Motion stays for component-level animations: hover, tap, layout)
- Dot grid background → replaced with more dramatic ambient treatment

### Performance Budget
- **Initial load budget:** < 250KB gzipped (before Three.js loads)
- **Total after interaction:** < 305KB gzipped (including lazy-loaded Three.js)
- **First Contentful Paint:** < 1.5s
- **Largest Contentful Paint:** < 2.5s
- **Three.js scene:** Lazy-loaded, renders only above fold. Falls back to CSS gradient on mobile/low-power.
- **`prefers-reduced-motion`:** All scroll animations degrade to instant reveals. Three.js scene becomes static.

**If over budget — cut priority (highest priority = cut last):**
1. Reduce Three.js particle count (100 → 50 → 20)
2. Remove bento circuit background pattern
3. Remove preloader animation (instant show)
4. Replace Three.js entirely with CSS-only hero (last resort)

---

## 3. Typography Strategy

### Shift: Quiet → Bold

**v4:** Playfair Display (serif) + Inter. Elegant, reserved.  
**v5:** Keep Inter for body, but replace Playfair with a bolder display face.

**Recommended display font:** **Space Grotesk** (bold, geometric, technical but warm) or **Syne** (distinctive, modern, slightly weird). Both are Google Fonts, free.

- Space Grotesk = more Nerdy Idealist (clean, engineering vibe)
- Syne = more Bold Builder (distinctive, opinionated)

**Recommendation:** Space Grotesk for headings, Inter for body, JetBrains Mono for code/terminal.

### Scale
| Element | Size | Weight | Tracking |
|---------|------|--------|----------|
| Hero headline | `clamp(4rem, 10vw, 8rem)` | 700 | -0.03em |
| Section headline | `clamp(2.5rem, 6vw, 5rem)` | 700 | -0.02em |
| Section subtitle | `clamp(1rem, 1.5vw, 1.25rem)` | 400 | 0 |
| Body | 1rem (16px) | 400 | 0 |
| Labels/tags | 0.75rem (12px) | 500 | 0.05em uppercase |
| Terminal | 0.875rem (14px) | 400 (mono) | 0 |

Hero headline goes **much bigger** than v4 (was `clamp(3rem,7vw,6rem)`). References consistently use oversized type as spectacle. The headline should dominate the viewport.

---

## 4. Color Strategy

### Base Palette (evolved from v4)

```
Background:     #08080A  (darker than v4's #0C0C0E — deeper black)
Surface:        #111114  (cards, elevated elements)
Border:         rgba(255,255,255,0.06)  (unchanged — works well)
Text Primary:   #F0F0F2  (slightly brighter)
Text Secondary: #8E8E93  (unchanged)
Text Muted:     #4A4A4E  (slightly darker for better hierarchy)
```

### Agent Accent Colors (bolder than v4)

Each agent gets a **bold, saturated accent** used for their dedicated section moment:

| Agent | Color | Hex | Usage |
|-------|-------|-----|-------|
| Admin (Popo) | Electric Blue | `#2D7FF9` | Orchestration moments, connecting lines |
| Thinker (Kanye) | Deep Violet | `#7C3AED` | Research/analysis scenes |
| Creator (Tyler) | Neon Emerald | `#10B981` | Build/creation moments |
| Gatekeeper (Rocky) | Amber/Gold | `#F59E0B` | Review checkpoints, approval glow |

**Change from v4:** Gatekeeper moves from red (#EF4444) to amber/gold. Red implies danger/error — Gatekeeper is about quality and approval, which gold better represents.

### Accent Lighting
Each agent's section gets a subtle radial glow in their color at ~5-8% opacity. When an agent's section is active (in viewport), their color subtly pulses. This creates the "dramatic lighting" feel from the references without WebGL.

---

## 5. Page Structure — Section by Section

The page is a **linear narrative in 8 acts**. Each section is approximately one viewport tall (some pin for scroll-driven animation). Total scroll length: ~6-8 viewports.

---

### Section 1: HERO — "The Opening Shot"
**Viewport:** Full screen, scroll-pinned for 1.5x viewport scroll  
**Inspiration:** landonorris.com hero (oversized type, full-bleed), igloo.inc (dark immersive atmosphere)

**Preloader (Section 0):** CSS-only. No canvas. Simple animated logo mark — 4 dots in agent colors positioned as a diamond, connected by thin CSS lines that draw in via `stroke-dashoffset` animation (SVG inline). Total duration: 1.5s. Fades out when page is ready. **Note:** No logo asset exists yet — Creator designs a minimal geometric mark (4 connected nodes) as part of this work. Keep it simple: circles + lines, not a polished brand logo. This is scope-light (30min max).

**Layout:**
- Three.js canvas fills the entire viewport (behind content)
- 3D scene: **Neural Network Mesh** — interconnected nodes (4 prominent ones in agent colors) with data particles flowing between them. Nodes slowly orbit. On scroll, the mesh compresses/expands.
- Centered headline: `"Four Agents.\nOne Machine."` — Space Grotesk 700, massive (`clamp(4rem,10vw,8rem)`)
- Subtitle fades in below: `"An AI squad that thinks, builds, reviews, and ships — on a single VM."` — Inter 400, text-secondary
- No CTA button. Instead: a minimal scroll indicator (thin animated chevron or line)
- On scroll (during pin): headline parallaxes up slowly, 3D mesh zooms in slightly, opacity reduces — transitioning into Section 2

**Animation:**
- Headline: split-text reveal, each word fades up with 80ms stagger
- Subtitle: fade-up 400ms after headline completes
- 3D mesh: continuous gentle rotation, particles flow. On scroll: camera pushes forward slightly
- Mobile fallback: CSS mesh gradient (animated with hue-rotate) replaces Three.js

**Hero Fallback Spec (mobile/SSR/reduced-motion):**
- Background: radial gradient from `#7C3AED` at 8% opacity center → `#08080A` edges, plus a secondary radial from `#2D7FF9` at 5% opacity offset top-right
- Subtle animation: `hue-rotate(360deg)` over 20s loop + slow `scale(1.0 → 1.05)` breathe (8s ease-in-out)
- 4 small CSS dot elements (8px, agent colors, 30% opacity) positioned at tetrahedral-ish offsets, gentle float animation
- On SSR: static gradient, no animation. Must look intentional — "moody dark hero", not "broken placeholder"
- `prefers-reduced-motion`: static gradient only, no animation

**Three.js Scene Spec:**
- 4 sphere nodes (r=0.3) at tetrahedral positions, each agent's color as emissive material
- ~100 smaller particles orbiting between nodes (points geometry, size=0.05)
- Connecting lines between nodes (Line2 with gradient)
- Ambient light + 1 point light
- Post-processing: subtle bloom (UnrealBloomPass, strength=0.3)
- Target: 60fps on mid-range hardware. Particle count scales down on mobile.

---

### Section 2: THE SQUAD — "Meet the Crew"
**Viewport:** Scroll-pinned for 4x viewport scroll (one sub-scroll per agent)  
**Inspiration:** curvy.dk/beagle (scroll-hijacked product reveal), manayerbamate (bold personality per section)

This is the **signature section** — the biggest departure from v4's card grid.

**Mechanism:** The section pins in place. As the user scrolls, each agent is revealed one at a time in a full-viewport takeover. Think of it as a deck of slides controlled by scroll.

**Per-agent slide layout:**
```
┌─────────────────────────────────────┐
│                                      │
│  [Agent emoji]          [Agent color │
│                          radial glow]│
│  NICKNAME                            │
│  Role title                          │
│                                      │
│  "Quote in big italic type"          │
│                                      │
│  Short description paragraph         │
│                                      │
│  [tag] [tag] [tag] [tag]            │
│                                      │
│  ─── Currently: always building ──── │
│                                      │
└─────────────────────────────────────┘
```

**Details:**
- Nickname in Space Grotesk 700, `clamp(3rem,8vw,6rem)` — almost as big as hero
- Quote in Inter italic, `clamp(1.25rem,2.5vw,1.75rem)`, text-secondary
- Agent's accent color as a large radial gradient (15-20% opacity) positioned top-right
- Tags as small pills with agent's chipColor border
- "Currently:" line in mono, simulating a live status — subtle blinking cursor at end
- Transition between agents: crossfade with slight y-translation (300ms)

**Scroll behavior:**
- Section pins when top hits viewport top
- Each 25% of the pin-scroll reveals the next agent
- Progress indicator: 4 small dots on the right edge, active dot = current agent's color
- Order: Admin → Thinker → Creator → Gatekeeper (pipeline order)
  - **Narrative logic:** Admin opens (receives task, orchestrates) → Thinker researches → Creator builds → Gatekeeper approves. Admin is first because they START the pipeline, not last. The motto "Think it → Build it → Check it → Ship it" maps to the *action flow*, while the squad reveal maps to the *org chart flow*. Both are valid — the reveal order prioritizes "who you meet first" (the coordinator).

**Mobile:** Same scroll-pinned behavior, but simplified — no radial glow, tighter spacing.

---

### Section 3: THE PIPELINE — "How It Flows"
**Viewport:** ~1.5 viewports, scroll-triggered animation  
**Inspiration:** curvy.dk (step-by-step scroll reveal)

**Evolved from v4's PipelineFlow** — but bigger, bolder, more visual.

**Layout:** Full-width horizontal pipeline visualization.

```
  ┌──────┐    ┌──────┐    ┌──────┐    ┌──────┐
  │THINK │───→│BUILD │───→│CHECK │───→│ SHIP │
  │  🧠  │    │  🎨  │    │  🛡️  │    │  🚓  │
  └──────┘    └──────┘    └──────┘    └──────┘
```

But rendered as:
- 4 large rounded rectangles (120x120px) with agent emoji centered
- Connected by animated dashed lines with traveling particles (CSS animation, not Three.js)
- Each step label below in Space Grotesk 600, agent color
- As user scrolls, steps light up left-to-right (GSAP ScrollTrigger with scrub)
- Active step gets: scale(1.05), box-shadow glow in agent color, label brightens
- Connecting line fills with color as scroll progresses (like a progress bar)

**Below the pipeline:** The team motto in large italic type:
> *"Think it, build it, check it, ship it — squad never slippin'"*

**Mobile:** Vertical pipeline (top-to-bottom), same scroll-trigger logic.

---

### Section 4: THE MISSION — "Watch It Happen" (Live Terminal)
**Viewport:** Scroll-pinned for 2x viewport scroll  
**Inspiration:** Active Theory (narrative experience), curvy.dk (scroll-as-playback)

**Evolved from v4's Terminal** — now scroll-driven instead of time-based.

**Concept:** A full-width terminal window. As the user scrolls, terminal lines appear one by one. Each line is a real step from a squad task. The scroll IS the playback control.

**Layout:**
```
┌─ pipeline ──────────────────────────────┐
│                                          │
│ $ new-task --type "landing-page"         │
│                                          │
│ [Admin]      📥 Task received            │
│ [Admin]      📤 HANDOFF → Thinker        │
│ [Thinker]    📥 PICKUP: Research + spec  │
│ [Thinker]    ⏳ Analyzing 7 references...│
│ [Thinker]    ✅ Spec complete (13K words)│
│ [Creator]    📥 PICKUP: Build from spec  │
│ [Creator]    ⏳ Next.js + Tailwind...    │ ← cursor here (scroll to reveal more)
│                                          │
│                                          │
└──────────────────────────────────────────┘
```

**Scroll behavior:**
- Terminal section pins in place
- Each ~50px of scroll reveals the next line (with typewriter effect)
- Agent names colored in their accent color
- Success lines (✅) get a brief green flash
- Final line: `[Gatekeeper] ✅ APPROVED: Ship it 🚀` triggers a celebration micro-animation (subtle confetti particles from agent colors, 1s duration)

**Terminal styling:**
- Background: `#0A0A0C` (slightly darker than page bg)
- Border: `1px solid rgba(255,255,255,0.08)`, `border-radius: 16px`
- Window chrome: 3 dots (muted), tab labeled "pipeline"
- Font: JetBrains Mono 14px
- Glow effect: subtle inner shadow in currently-typing agent's color
- **Status bar data:** `4 agents online | uptime: 847h | tasks completed: 2,847` — **(a) hardcoded placeholder**. No live endpoint, no randomization. Just static impressive-looking numbers. Creator can pick numbers that look good. If we want live data later, that's a v6 feature.

**Mobile:** Same but no pin — just scroll-reveal with intersection observer. Lines appear as they enter viewport.

---

### Section 5: THE STACK — "What Powers It"
**Viewport:** ~1.5 viewports  
**Inspiration:** manayerbamate (bold sections with personality)

**Evolved from v4's BentoGrid** — tighter, more opinionated.

**Layout:** Asymmetric bento grid, 3 columns on desktop.

```
┌──────────────┬──────────┐
│              │          │
│   OpenClaw   │  Claude  │
│   (large)    │  (med)   │
│              │          │
├──────┬───────┼──────────┤
│Slack │ Queue │  60+     │
│(sm)  │ (sm)  │  Skills  │
│      │       │  (med)   │
├──────┴───────┼──────────┤
│   Shared     │  Single  │
│   Context    │  VM      │
│   (med)      │  (sm)    │
└──────────────┴──────────┘
```

**Each tile:**
- Icon (emoji) top-left, 24px
- Title in Space Grotesk 600
- 1-line description in Inter 400, text-secondary
- Background: `#111114` with subtle border
- Hover: slight lift (translateY -2px) + border brightens

**Scroll animation:** Tiles stagger-reveal from bottom, 60ms delay between each (GSAP ScrollTrigger).

The large "OpenClaw" tile gets special treatment:
- Subtle animated grid pattern in background (CSS only)
- Slightly brighter border
- "The engine" as a label above the title

---

### Section 6: BEHIND THE SCENES — "The Architecture"
**Viewport:** ~1 viewport  
**NEW section** (not in v4)

A simplified architectural diagram showing how the 4 agents coordinate:

```
                    ┌──────────┐
                    │ Xiaosong │
                    │ (Human)  │
                    └────┬─────┘
                         │
                    ┌────▼─────┐
                    │  Admin   │
                    │  (Popo)  │
                    └──┬───┬───┘
                   ┌───┘   └───┐
              ┌────▼──┐   ┌───▼────┐
              │Thinker│   │Creator │
              │(Kanye)│   │(Tyler) │
              └───┬───┘   └───┬────┘
                  └─────┬─────┘
                   ┌────▼─────┐
                   │Gatekeeper│
                   │ (Rocky)  │
                   └──────────┘
```

**Rendered as:** Clean SVG diagram with animated connection lines. Nodes pulse with agent colors. Data flow particles travel along the lines.

**Implementation:** Pure SVG + CSS animations. No Three.js needed. GSAP draws the connections on scroll-enter.

**Below the diagram:** 3 stat cards in a row:
- `1 VM` / "All four agents, one machine"
- `24/7` / "Always running, always shipping"  
- `~30s` / "Average task handoff time"

---

### Section 7: CTA — "Join the Squad"
**Viewport:** ~0.8 viewport  
**Inspiration:** landonorris.com (bold CTA moment)

**Layout:**
- Centered, generous whitespace
- Headline: `"Want your own squad?"` — Space Grotesk 700, large
- Subtitle: `"OpenClaw is open source. Set up four agents on any machine."` — Inter 400
- Two CTAs side by side:
  - Primary: `"Get Started →"` (filled pill, accent color gradient border with subtle animation)
  - Secondary: `"View on GitHub"` (ghost pill, border only)
- Below CTAs: `"Built with OpenClaw • Powered by Claude"` in text-muted

**Animation:** Section fades up. CTAs have a subtle shimmer on the border (CSS `background-size` animation on gradient).

---

### Section 8: FOOTER
**Viewport:** Minimal (~0.3 viewport)

Simple, dark, elegant:
```
Squad Landing — Built by the squad, for the squad.
OpenClaw • GitHub • Discord
© 2026
```

Three links centered. No columns, no bloat. Text-muted with hover to text-secondary.

---

## 6. Motion Strategy

### Scroll Engine: Lenis
- Smooth scroll with `duration: 1.2`, `easing: (t) => Math.min(1, 1.001 - Math.pow(2, -10 * t))`
- Touch devices: native scroll (Lenis adds smooth only on pointer devices)
- Wrapper component: `<SmoothScroll>` wrapping the entire page

### Scroll Animations: GSAP ScrollTrigger
All scroll-driven animations use GSAP ScrollTrigger with `scrub: true` for buttery scroll-linked motion.

| Section | Pin | Scrub | Duration |
|---------|-----|-------|----------|
| Hero | Yes (1.5x) | Yes | Parallax + fade |
| Squad | Yes (4x) | Yes | Agent transitions |
| Pipeline | No | Yes | Step-by-step light up |
| Terminal | Yes (2x) | Yes | Line-by-line reveal |
| Stack | No | No (trigger only) | Stagger reveal |
| Architecture | No | Yes | SVG draw |
| CTA | No | No (trigger only) | Fade up |

### Component Animations: Framer Motion
Framer Motion handles:
- Hover/tap states on interactive elements
- Layout animations on agent card transitions
- Spring physics on buttons and tags
- `AnimatePresence` for crossfade between agent slides

### Performance Rules
1. All scroll animations use `transform` and `opacity` only (GPU-composited)
2. No layout-triggering properties in animations
3. `will-change: transform` on pinned elements
4. GSAP `fastScrollEnd: true` + `preventOverlaps: true`
5. Three.js scene pauses rendering when below fold (`useFrame` checks visibility)

---

## 7. What to Keep from v4

| Keep | Why |
|------|-----|
| `lib/agents.ts` data structure | Good data model, just update colors |
| `Terminal` concept | Core differentiator — evolve, don't replace |
| `PipelineFlow` concept | Signature moment — make it bigger |
| Dark theme direction | Correct instinct, push darker |
| Framer Motion `SplitText` | Reuse for hero animation |
| Static export (`output: 'export'`) | Keep deployment simple |

| Replace | Why |
|---------|-----|
| `TeamGrid` card layout | → Scroll-pinned full-viewport agent reveals |
| `BentoGrid` component | → Rebuild with GSAP stagger + new tile sizes |
| `Hero` (current) | → Three.js hero + pinned scroll |
| `CTASection` | → Bigger, bolder, with dual CTAs |
| Playfair Display font | → Space Grotesk (bolder, more technical) |
| Framer Motion scroll reveals | → GSAP ScrollTrigger (more control) |
| `ScrollReveal` wrapper | → GSAP-based equivalent |

---

## 8. Responsive Breakpoints

| Breakpoint | Behavior |
|------------|----------|
| ≥1280px (xl) | Full experience — 3D hero, all pins, full pipeline |
| ≥768px (md) | 3D hero (reduced particles), all pins, horizontal pipeline |
| 768-1023px (tablet) | 2-column agent grid (not full-viewport per agent — would feel sparse), pins retained, horizontal pipeline |
| <768px (sm) | CSS gradient hero (no Three.js), no scroll pins (scroll-reveal instead), vertical pipeline, stacked bento |

**Mobile-specific:**
- All scroll-pinned sections become scroll-reveal (IntersectionObserver triggers)
- Three.js scene → animated CSS gradient with mesh-like pattern
- Agent reveals → swipeable cards or vertical scroll
- Terminal → no pin, lines reveal on scroll-into-view
- Touch: Lenis disabled (native scroll)

---

## 9. File Structure (proposed)

```
app/
  layout.tsx          (fonts, Lenis wrapper, metadata)
  page.tsx            (section composition)
  globals.css         (base styles, Lenis overrides)

components/
  Hero/
    Hero.tsx          (container: 3D + content + scroll pin)
    NeuralMesh.tsx    (R3F Three.js scene — lazy loaded)
    HeroFallback.tsx  (CSS gradient fallback for mobile/reduced-motion)
  Squad/
    SquadSection.tsx  (scroll-pinned container)
    AgentSlide.tsx    (individual agent full-viewport layout)
    ScrollDots.tsx    (navigation dots)
  Pipeline/
    Pipeline.tsx      (scroll-scrubbed step animation)
  Terminal/
    Terminal.tsx      (scroll-driven terminal replay)
  Stack/
    StackGrid.tsx     (bento grid with stagger)
    StackTile.tsx     (individual tile)
  Architecture/
    Architecture.tsx  (SVG diagram + animations)
  CTA/
    CTA.tsx
  Footer/
    Footer.tsx
  shared/
    SmoothScroll.tsx  (Lenis wrapper)
    SplitText.tsx     (text animation — keep from v4)

lib/
  agents.ts           (agent data — update colors)
  terminal-lines.ts   (terminal sequence data)
  scroll.ts           (GSAP ScrollTrigger setup helpers)
```

---

## 10. Implementation Notes for Creator

### Priority Order
1. **Lenis + GSAP setup** — get smooth scroll and pinning working first
2. **Hero** (CSS fallback first, Three.js last) — the first impression
3. **Squad section** (scroll-pinned agent reveals) — the signature differentiator
4. **Terminal** (scroll-driven) — the "product demo"
5. **Pipeline** (scroll-scrubbed) — the motto moment
6. **Stack bento** — straightforward
7. **Architecture SVG** — nice-to-have, can be cut if timeline is tight
8. **Three.js hero** — add last, as an enhancement layer

### Gotchas
- GSAP ScrollTrigger + Lenis need integration: use `lenis.on('scroll', ScrollTrigger.update)` and `gsap.ticker.add((time) => lenis.raf(time * 1000))`
- Three.js with Next.js static export: use dynamic import with `ssr: false`
- GSAP is **not** MIT — it's free for most uses but check the license for commercial projects. For an open-source showcase page, it's fine.
- ScrollTrigger pins can fight with Lenis. Test early. Use `ScrollTrigger.scrollerProxy()` if needed.
- JetBrains Mono: load via Google Fonts (`next/font/google`) or self-host for performance

### Copy Tone
The copy should feel like the agents are talking to you. Not corporate. Not try-hard. Confident, slightly playful, technical but accessible. Think: "We built something cool. Here's how it works. Want in?"

**Note:** Section 2 "The Premise" copy ("What if your AI didn't just answer questions?") is **TBD placeholder** — needs polish before Creator builds it. Thinker will provide final copy in a follow-up. Creator can use placeholder text and swap later.

### Font Loading Strategy
- Space Grotesk + Inter: load via `next/font/google` as before
- JetBrains Mono: **lazy load** — only fetch when terminal section enters viewport (dynamic `<link>` injection or CSS `font-display: swap` with late preload). Alternatively, subset to ASCII-only (~15KB). Don't load it upfront.

### Noise Texture
Use a static SVG pattern or CSS `background-image` with a tiny repeating noise PNG — NOT a `<canvas>` element. Keeps it simple.

### Three.js in CTA
Do NOT reuse the hero Three.js scene in the CTA section. Hero gets Three.js, CTA gets a CSS-only echo: matching gradient + subtle CSS dot particles (animated `box-shadow` or pseudo-elements). Simpler, avoids keeping WebGL context mounted through 6 sections or re-instantiation flash.

### Accent Color
Confirmed: shifting from `#8B5CF6` (v4) to `#7C3AED` (v5) — more saturated violet. Team-aligned.

---

## 11. Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| GSAP + Lenis integration complexity | High | Implement scroll engine first, test pinning before building sections |
| Three.js bundle size | Medium | Lazy load, tree-shake, mobile fallback. Only one small scene. |
| Scroll-pinned sections feel janky on some devices | High | Extensive testing. Fallback to reveal-on-scroll if pin doesn't work smoothly. |
| Too many scroll pins = confusing UX | Medium | Max 3 pinned sections (Hero, Squad, Terminal). Rest are normal scroll. |
| Space Grotesk doesn't pair well with Inter | Low | Test early. Fallback: use Inter for everything with weight variation. |
| Mobile experience feels stripped | Medium | Design mobile-first for the reveal version, ensure it's still impressive without pins/3D. |

---

## 12. Success Criteria

The v5 page should feel like you're watching a **live system operate**, not reading a marketing page. Visitors should:

1. **Feel the narrative** — scroll drives a story from "meet the squad" to "watch them work" to "get your own"
2. **Remember the agents** — each gets a full-viewport moment with personality
3. **Understand the pipeline** — the terminal section makes it tangible and real
4. **Want to try it** — the CTA feels earned, not forced
5. **Be impressed technically** — smooth animations, dark dramatic aesthetic, 3D touch

If someone screenshots a section and shares it, we've won.

---

## 13. Gatekeeper Review Log

**First review (1772118227):** Conditional approval — 5 clarifications needed.
**Clarifications addressed:**
1. ✅ Bundle budget: defined initial (250KB) vs total (305KB) + priority cut order
2. ✅ Hero fallback: fully specced (gradient colors, animation, SSR, reduced-motion)
3. ✅ Agent order: clarified Admin-first narrative logic vs motto action flow
4. ✅ Preloader: CSS-only, no logo asset exists — Creator designs minimal 4-node mark (~30min)
5. ✅ Terminal status bar: hardcoded placeholder, no live data

**Second review (1772118266):** Approved ✅ with 6 minor notes — all incorporated:
1. Bundle budget split (initial vs interaction) ✅
2. Tablet breakpoint (2-column grid) ✅
3. Preloader CSS-only (no canvas) ✅
4. JetBrains Mono lazy loading ✅
5. Section 2 copy flagged as TBD ✅
6. CTA = CSS-only, no Three.js reuse ✅

**Scope estimate:** 12-16h (Gatekeeper's assessment). This is a near-full rebuild, not an iteration.
