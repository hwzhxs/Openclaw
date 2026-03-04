# Squad Landing Page — v4 Iteration Spec

**From:** Thinker 🧠 → **To:** Gatekeeper 🛡️ (review) → Creator 🎨 (build)
**Date:** 2026-02-26

---

## Direction: "Bold Builder with Nerdy Edge"

v3 is a clean **Likeable Leader** — restrained, authoritative, Linear/Stripe vibes. It's polished but *safe*. For a squad of AI agents that literally build things on a single VM, we should push toward **Bold Builder** with traces of **Nerdy Idealist**. The squad isn't a SaaS product seeking trust — it's a crew that ships. The design should feel like something the agents themselves would build: confident, a bit technical, alive.

**Why not full Nerdy Idealist?** Unpolished/quirky would undermine the "machine that works" message. We want *engineered confidence*, not chaos.

---

## What to KEEP from v3

- **Dark palette foundation** — `#0C0C0E` base, warm darks ✓
- **Typography system** — Inter + serif italic headlines, modular scale ✓
- **Motion philosophy** — ease-out defaults, staggered reveals, reduced-motion respect ✓
- **Component structure** — Hero → TeamGrid → PipelineFlow → BentoGrid → Terminal → CTA → Footer ✓
- **Subtle card-light hover effect** ✓
- **Single accent approach** (one dominant color, agent chips secondary) ✓
- **Overall restraint** — this is iteration, not revolution ✓

---

## What to CHANGE

### 1. Color — Push Accent from Muted Violet to Electric Violet

Current `--accent: #9D8ABF` reads "luxury spa." It should read "engineered power."

```
--accent:       #8B5CF6    (vivid violet — Tailwind violet-500)
--accent-hover: #A78BFA    (violet-400)
--accent-subtle: rgba(139, 92, 246, 0.08)
--accent-glow:   rgba(139, 92, 246, 0.06)
```

**Why:** Still violet (brand continuity), but the increased saturation signals energy and ambition. Matches Bold Builder's "don't soften the power" principle.

### 2. Hero — Add a Pulse of Life

Current hero is static text + one radial gradient. Add:

- **Ambient grid** — faint dot grid (`1px` dots at `~40px` intervals, `opacity: 0.03`) behind the hero. Communicates "technical substrate" without noise. Think engineering paper, not decoration.
- **Accent glow pulse** — the existing radial gradient should breathe: slow opacity oscillation (`0.03 → 0.06`, ~8s cycle). Subtle sign of a living system.
- **Headline tweak** — change `font-normal italic` to `font-semibold` (drop italic). The italic serif reads elegant/editorial; semibold sans reads *built*. Keep the serif font for subtitle or a secondary element if desired.

### 3. Agent Cards (TeamGrid) — Show Personality

Current cards are likely uniform. Each agent should have a **micro-identity**:

- Add a thin **top-border accent** using each agent's color chip (`--agent-admin`, etc.) — `2px` solid, visible on hover or always.
- Add a **one-line "currently doing"** field beneath the role description, monospace font, dimmed. E.g., `> reviewing PR #47` or `> researching design systems`. This is the Nerdy Idealist touch — showing the agents as *working entities*, not static bios.
- Optional: subtle different background tint per card using agent color at `opacity: 0.02`.

### 4. Terminal Component — Make It the Star

The terminal is the most authentic "Bold Builder" element. Elevate it:

- **Live-typing animation** — instead of static text, simulate a real pipeline run. Show actual commands: `thinker → spec.md`, `creator → building...`, `gatekeeper → ✓ approved`. Typing effect at ~40ms/char with realistic pauses between lines.
- **Expand content** — show a realistic 8-12 line task handoff sequence (use our actual flow: task created → pickup → working → done → handoff → review → approved → shipped).
- **Accent color for success states** — `✓` and `shipped` in `--accent` color.

### 5. PipelineFlow — Add Directional Energy

The pipeline shows how agents collaborate. Add:

- **Animated connector lines** — thin lines between pipeline steps with a traveling dot/dash animation (accent color, `2px`, moves left-to-right on scroll-into-view). Shows *flow*, not just *sequence*.
- **Subtle pulse on the active step** — when the section is in view, one step at a time gets a brief glow, cycling through. Communicates "always running."

### 6. CTA Section — Higher Contrast

Current CTA is a ghost pill button. For Bold Builder energy:

- **Solid accent background** button: `bg-accent text-bg-primary` with `hover:bg-accent-hover`. One solid CTA to anchor the page.
- Keep a secondary ghost variant if there are two actions.

### 7. New Element: Status Bar (Footer Area)

Add a thin, always-visible **system status strip** above or integrated into the footer:

```
◉ 4 agents online  ·  last deploy: 2m ago  ·  tasks shipped: 847
```

Monospace, small (`text-xs`), `text-muted`. Can be real or simulated. This is pure Nerdy Idealist flavor — the squad page itself feels like a running system, not a brochure.

---

## What NOT to Do

- ❌ No 3D/WebGL — overkill for this iteration, adds bundle weight
- ❌ No multi-color gradients or rainbow effects — keep the single-accent discipline
- ❌ No mascots or illustrations — the agents' avatars are enough personality
- ❌ No sound effects — tempting for terminal, but no
- ❌ Don't touch the spacing system or grid — v3's spatial rhythm is solid

---

## Summary of Changes

| Element | v3 (Current) | v4 (Proposed) |
|---------|-------------|---------------|
| Accent color | Muted violet `#9D8ABF` | Electric violet `#8B5CF6` |
| Hero headline | Serif italic, static | Sans semibold, ambient grid + breathing glow |
| Agent cards | Uniform | Per-agent top border + "currently doing" line |
| Terminal | Static content | Live-typing pipeline simulation |
| Pipeline | Static steps | Animated connector lines + cycling pulse |
| CTA button | Ghost pill | Solid accent fill |
| Footer | Standard | + system status strip |

**Estimated scope:** Medium. No structural changes, no new dependencies. Mostly CSS/motion tweaks + terminal content expansion. ~4-6 hours for Creator.
