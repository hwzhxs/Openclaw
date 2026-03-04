# Landing Page Spec — The Squad 🎤🧠🛡️🛠️

**Author:** Thinker (Kanye) 🧠
**For:** Creator (Tyler) 🛠️ to build
**Status:** Draft → Gatekeeper review → Build

---

## 1. Overview

A single-page, dark-mode, Awwwards-quality site introducing our 4-agent squad. Vibe: **Linear meets a crew intro page**. Dark, clean, animated, confident. Not corporate — this is a squad, not a startup.

**URL:** TBD (local dev first)
**Viewport:** Desktop-first, responsive down to mobile
**Tone:** Confident, slightly playful, technical but accessible

---

## 2. Page Sections

### 2.1 — Hero (Full Viewport)

**Layout:** Centered, full-screen. Dark gradient background with subtle animated grain/noise texture.

**Copy:**
- **Headline:** `Four Agents. One Machine. Zero Chill.`
- **Subtitle:** `We're a squad of AI agents running on a single VM — thinking, building, reviewing, and shipping around the clock.`
- **CTA Button:** `Meet the Squad ↓` (smooth scrolls to team section)

**Animation:**
- Background: Subtle animated gradient (dark navy → deep purple → black, slow 8s cycle)
- Grain overlay: CSS noise texture at 3-5% opacity, animated
- Headline: Fade up + letter stagger (GSAP SplitText or manual), 600ms total, `cubic-bezier(0.16, 1, 0.3, 1)`
- Subtitle: Fade up 200ms after headline
- CTA: Fade up 400ms after headline, subtle pulse glow on idle

**Visual notes:**
- No hero image — typography IS the hero
- Consider a subtle particle field or constellation effect in background (Three.js, keep it minimal)

---

### 2.2 — The Squad (Team Grid)

**Layout:** 2×2 grid on desktop, single column on mobile. Each agent gets a card.

**Card structure:**
```
┌──────────────────────────────┐
│  [Emoji/Avatar — large]      │
│                              │
│  Nickname                    │
│  Role Title                  │
│  ─────────                   │
│  One-liner description       │
│                              │
│  "Signature quote"           │
│                              │
│  [Skills tags]               │
└──────────────────────────────┘
```

**Agent Copy:**

**Popo 👮 — Admin (xXx) 🎤**
- Role: `The Orchestrator`
- One-liner: `Keeps the chaos organized and the team on beat. Assigns tasks, coordinates handoffs, and makes sure nothing falls through the cracks.`
- Quote: `"Everybody eats. Nobody sleeps."`
- Tags: `Coordination` `Task Routing` `Context Keeper` `Slack Ops`

**Kanye 🧠 — Thinker**
- Role: `The Researcher`
- One-liner: `Goes down rabbit holes so you don't have to, then comes back with a map. Deep analysis, structured plans, and options with tradeoffs.`
- Quote: `"Give me three options and I'll give you the fourth."`
- Tags: `Research` `Analysis` `Planning` `Specs`

**Rocky 🛡️ — Gatekeeper**
- Role: `The Reviewer`
- One-liner: `If it's not solid, it's not shipping. Every deliverable passes through Rocky's quality gauntlet before it sees daylight.`
- Quote: `"It ain't done till I say it's done."`
- Tags: `Code Review` `Quality` `Security` `Standards`

**Tyler 🛠️ — Creator**
- Role: `The Builder`
- One-liner: `Turns specs into reality, one commit at a time. 18 skills loaded, dark mode by default, ships by midnight.`
- Quote: `"Spec? Read. Building? Started. ETA? Now."`
- Tags: `React` `Next.js` `Animation` `Full-Stack`

**Card styling:**
- Background: `#1C1C1E` (elevated dark surface per design system)
- Border: 1px `rgba(255,255,255,0.06)`
- Border-radius: 16px
- Padding: 32px
- Hover: translate-y -4px, border glows with agent's accent color, shadow lift
- Each agent gets a subtle accent color for their card glow:
  - Popo: Blue `#3B82F6`
  - Kanye: Purple `#8B5CF6`
  - Rocky: Red `#EF4444`
  - Tyler: Green `#10B981`

**Animation:**
- Cards stagger in on scroll (50ms delay each), fade-up + scale from 0.95
- Tags animate in after card (stagger 30ms each)
- Emoji/avatar has subtle float animation on idle (translateY ±4px, 3s ease-in-out loop)

---

### 2.3 — How We Work (Flow Diagram)

**Layout:** Horizontal flow on desktop (scrolls if needed), vertical on mobile.

**Headline:** `The Pipeline`
**Subtitle:** `Every task flows through the squad. No shortcuts, no skipped steps.`

**Flow steps:**

```
📥 Task In → 🎤 Admin Routes → 🧠 Thinker Researches → 🛠️ Creator Builds → 🛡️ Gatekeeper Reviews → ✅ Shipped
```

With a branch:
```
🛡️ Gatekeeper → ❌ Rejected → 🔄 Back to source → iterate
```

**Visual:**
- Horizontal connected nodes with animated line drawing between them
- Each node: circle with emoji + label below
- Active step pulses with glow
- Connecting lines: animated SVG path draw (GSAP drawSVG or CSS stroke-dashoffset)
- Line color: gradient matching agent accent colors as it flows through

**Animation:**
- Scroll-triggered: line draws left-to-right as user scrolls through section
- Nodes light up sequentially as line reaches them
- The rejection branch animates with a red flash + bounce-back
- Total animation: 800ms per node, staggered

**Copy for each node:**

| Step | Label | Detail (appears on hover or below) |
|---|---|---|
| 📥 | Task In | File drops into `shared/tasks/` via handoff |
| 🎤 | Route | Admin assigns to the right agent |
| 🧠 | Research | Thinker digs deep, writes specs & plans |
| 🛠️ | Build | Creator ships code from spec |
| 🛡️ | Review | Gatekeeper checks quality, security, correctness |
| ✅ | Ship | Approved deliverable posted to Slack |

---

### 2.4 — The Stack

**Headline:** `Built Different`
**Subtitle:** `Four agents, one VM, zero cloud bills. Here's what's under the hood.`

**Layout:** Bento grid (mixed sizes). 3 columns desktop, 1 column mobile.

**Tiles:**

| Tile | Size | Content |
|---|---|---|
| Runtime | Large (2-col) | **OpenClaw** — Agent orchestration framework. Gateway, webhooks, heartbeats, task queue. |
| Model | Medium | **Claude via GitHub Copilot** — The brain behind all four agents. |
| Comms | Medium | **Slack + Webhooks** — Real-time coordination. Threaded task tracking. |
| OS | Small | **Windows VM** — Single machine, all four agents running simultaneously. |
| Queue | Small | **File-based task queue** — Markdown handoff files. Simple, reliable, human-readable. |
| Skills | Medium | **60+ skills** — Research, coding, design, TTS, weather, and more. |
| Memory | Small | **Shared context** — TEAM-MEMORY.md + daily logs. Agents remember across sessions. |

**Tile styling:**
- Same card style as team cards
- Icon/emoji top-left
- Title bold, description regular weight
- Hover: subtle background lighten + scale 1.01
- Some tiles could have animated backgrounds (code rain for Runtime, waveform for Comms)

**Animation:**
- Stagger in on scroll (40ms per tile)
- Fade up + scale from 0.97

---

### 2.5 — Proof (Terminal)

**Headline:** `Live From the Terminal`
**Subtitle:** `Real output from real tasks.`

**Layout:** Fake terminal window, dark, monospace font.

**Content:** Auto-typing terminal showing a real task flow:

```
$ cat shared/tasks/20260225-thinker-to-gatekeeper.md

# Task Handoff
- From: Thinker 🧠
- To: Gatekeeper 🛡️
- Priority: normal

## Task
Review landing page spec for quality and completeness.

$ slack --channel #agent-team
📥 PICKUP: Landing page spec review (from Thinker)
⏳ WORKING: Checking section structure, copy, animations...
✅ APPROVED: Spec is solid. Ship it.
📤 HANDOFF → Creator 🛠️: Build from spec.
```

**Animation:**
- Terminal text types out character by character (40ms/char for commands, 15ms/char for output)
- Cursor blinks during "typing"
- Lines appear in sequence with realistic pauses between commands (800ms)
- Scroll-triggered start

**Styling:**
- Background: `#0A0A0A`
- Font: `JetBrains Mono` or `Fira Code`
- Green prompt, white text, colored emoji
- Window chrome: macOS-style dots (red/yellow/green) top-left
- Subtle glow around terminal (agent purple accent)

---

### 2.6 — CTA / Footer

**Layout:** Centered section, gradient background

**Copy:**
- **Headline:** `Want Your Own Squad?`
- **Subtitle:** `Built with OpenClaw. Open source. Run it on your own machine.`
- **CTA Button:** `Get OpenClaw →` (links to github.com/openclaw/openclaw)
- **Secondary link:** `Join the community →` (links to Discord)

**Footer below:**
- Minimal single line: `Built by the squad, on the squad. © 2026`
- Links: GitHub · Discord · docs.openclaw.ai

**Animation:**
- Gradient background: slow animated dark purple → dark blue shift
- CTA button: glow pulse on idle, scale 1.05 on hover
- Footer fades in last

---

## 3. Visual Direction

### Color Palette

| Token | Value | Usage |
|---|---|---|
| `--bg-primary` | `#0A0A0A` | Page background |
| `--bg-elevated` | `#1C1C1E` | Cards, tiles |
| `--bg-surface` | `#2C2C2E` | Hover states, inputs |
| `--text-primary` | `#F5F5F7` | Headings |
| `--text-secondary` | `#A1A1AA` | Body text, descriptions |
| `--text-muted` | `#71717A` | Tags, metadata |
| `--accent-blue` | `#3B82F6` | Popo / links / CTAs |
| `--accent-purple` | `#8B5CF6` | Kanye / primary brand accent |
| `--accent-red` | `#EF4444` | Rocky / errors |
| `--accent-green` | `#10B981` | Tyler / success |
| `--border` | `rgba(255,255,255,0.06)` | Card borders |
| `--glow` | `rgba(139,92,246,0.15)` | Purple glow effects |

### Typography

- **Font:** `Inter` (Google Fonts) — clean, modern, great for dark mode
- **Heading scale (modular 1.333):**
  - Hero: 72px / 700 / -0.03em
  - H2 (section): 48px / 700 / -0.02em
  - H3 (card title): 24px / 600
  - Body: 16px / 400 / line-height 1.6
  - Small/tags: 13px / 500 / uppercase / 0.05em tracking
- **Code:** `JetBrains Mono` 14px

### Spacing

- Section padding: 120px vertical (desktop), 80px (mobile)
- Card gap: 24px
- Max content width: 1200px
- 8px grid system throughout

---

## 4. Tech Stack

| Layer | Choice | Why |
|---|---|---|
| Framework | **Next.js 14** (App Router) | SSG for performance, React ecosystem |
| Styling | **Tailwind CSS** | Rapid iteration, design system tokens |
| Animation | **Framer Motion** + **GSAP** | Framer for component animations, GSAP for scroll timelines + text effects |
| 3D (optional) | **Three.js / R3F** | Hero background particles only — keep it light |
| Components | **Radix UI** primitives if needed | Accessible, unstyled |
| Font | **Inter** (Google Fonts) | Via `next/font` for performance |
| Code font | **JetBrains Mono** | Terminal section |
| Deploy | **Static export** or local dev | `next export` for simplicity |

---

## 5. Component Breakdown (for Creator)

| Component | Props/Notes |
|---|---|
| `<Hero />` | Animated gradient bg, SplitText headline, CTA button |
| `<AgentCard />` | `{ name, emoji, role, description, quote, tags, accentColor }` |
| `<TeamGrid />` | 2×2 grid of `<AgentCard />`, staggered scroll animation |
| `<PipelineFlow />` | SVG flow diagram with animated path drawing |
| `<PipelineNode />` | `{ emoji, label, detail }` — single node in flow |
| `<BentoGrid />` | Mixed-size tile grid |
| `<BentoTile />` | `{ icon, title, description, size }` |
| `<Terminal />` | Fake terminal with typing animation |
| `<TerminalLine />` | Single typed line with configurable speed |
| `<CTASection />` | Gradient bg, headline, buttons |
| `<Footer />` | Minimal links |
| `<GrainOverlay />` | CSS noise texture overlay |
| `<GlowEffect />` | Reusable glow/gradient blur behind elements |
| `<ScrollReveal />` | Wrapper: fade-up + optional stagger on scroll enter |
| `<SplitText />` | GSAP letter-by-letter animation for headings |

---

## 6. Interactions & Easter Eggs

### Interactions
- **Smooth scroll** between sections (CSS `scroll-behavior: smooth` or Lenis)
- **Agent card hover:** Border glows with accent color, card lifts, quote fades in
- **Pipeline nodes:** Hover shows detail tooltip
- **Terminal:** Hover pauses typing, click to "restart"
- **CTA button:** Magnetic hover effect (follows cursor slightly within bounds)
- **Nav (if added):** Blur backdrop on scroll, compact on scroll-down

### Easter Eggs (optional, if Creator has time)
- **Konami code** → squad emoji rain from top of screen
- **Click the terminal 5 times** → shows a real haiku from the team
- **Scroll to very bottom** → tiny text: `"Think it, build it, check it, ship it — squad never slippin'"`  (the team motto)

---

## 7. Responsive Notes

| Breakpoint | Changes |
|---|---|
| ≥1280px | Full layout as specced |
| 1024px | Team grid → 2×2, bento → 2 columns |
| 768px | Pipeline → vertical, bento → 1 column |
| <640px | Everything single column, hero text scales down (48px heading), section padding 64px |

---

## 8. Performance Budget

- **First paint:** <1.5s
- **Total JS:** <200KB gzipped (be aggressive with tree-shaking)
- **Images:** Minimal — emoji-based, no heavy assets
- **Fonts:** 2 max (Inter + JetBrains Mono), subset Latin
- **Animations:** GPU-accelerated only (transform, opacity). No layout triggers.
- **`prefers-reduced-motion`:** Disable all animations, show static layout

---

## 9. Files to Deliver

```
squad-landing/
├── app/
│   ├── layout.tsx
│   ├── page.tsx
│   └── globals.css
├── components/
│   ├── Hero.tsx
│   ├── AgentCard.tsx
│   ├── TeamGrid.tsx
│   ├── PipelineFlow.tsx
│   ├── BentoGrid.tsx
│   ├── Terminal.tsx
│   ├── CTASection.tsx
│   ├── Footer.tsx
│   └── shared/
│       ├── ScrollReveal.tsx
│       ├── SplitText.tsx
│       ├── GrainOverlay.tsx
│       └── GlowEffect.tsx
├── lib/
│   └── agents.ts (team data)
├── public/
│   └── (minimal assets)
├── tailwind.config.ts
├── next.config.js
└── package.json
```

---

_"Think it, build it, check it, ship it."_
