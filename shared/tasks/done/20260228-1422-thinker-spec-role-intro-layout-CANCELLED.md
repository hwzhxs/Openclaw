# Spec: Role Intro Section Layout Update (v8-mini patch)

**Author:** Thinker 🧠  
**Date:** 2026-02-28  
**Scope:** `AgentsScroll.tsx` — agent section layout only. No other sections affected.  
**Reference:** Xiaosong's screenshots (current deployed version he likes)

---

## What Xiaosong Wants

He likes the **current layout** shown in the screenshots. This spec documents it precisely so Creator can match it if rebuilding, and captures the specific design language for future reference.

## Current Layout (to preserve / replicate)

### Structure per Agent Section

Each agent section is a **full-viewport-height (`h-screen`) panel** with:

1. **Split layout** — two-column grid (`md:grid-cols-2`), alternating image/text sides per agent
2. **Gradient background** — unique per agent, full-bleed, 135° angle
3. **Section spotlight** — mouse-following radial glow using agent's primary color
4. **Vignette overlay** — radial gradient darkening edges

### Image Column

- **Portrait image** — full-height (`h-[68vh]`), `object-contain`, rounded-2xl
- **HUD corner brackets** — 2px lines at corners in agent's primary color, appear on hover
- **Scan line sweep** — horizontal line sweeps top-to-bottom on hover
- **Glow pulse** — box-shadow pulse on hover using agent color
- **Parallax** — subtle Y-axis parallax on scroll
- **Entry animation** — slides in from the side (left or right depending on position), with scale

### Text Column

Layout (top to bottom):

| Element | Style |
|---|---|
| **Ghost index** | Massive watermark number ("01", "02"...) — `clamp(8rem, 22vw, 20rem)`, agent primary color at 4.5% opacity, positioned behind content, opposite side from image |
| **Section number** | Small "01" with horizontal line — appears above name (visible in screenshot but currently rendered as emoji in code) |
| **Agent name** | Serif display font (`font-display`), `clamp(3rem, 7vw, 6.5rem)`, white, font-light |
| **Subtitle** | "The Police" / "The Creator" etc — in agent's primary color, italic/display style |
| **Role badge** | Pill with border — "• Admin" / "• Creator" — `rounded-full`, uppercase, tracking-widest, agent primary color border & text |
| **Divider** | 1px line, 4rem wide, agent accent color at 40% opacity |
| **Description** | `text-lg`, `text-white/55`, `max-w-xs`, `leading-relaxed` |
| **Code tag** | Monospace snippet like `<admin role="coordinator" status="online" />` — agent accent color, pulsing opacity animation |

### Key Differences from Screenshot vs Current Code

Looking at the screenshots closely vs the current `AgentsScroll.tsx`:

1. **Section number with line** — Screenshots show "01 ———" (number + horizontal rule) above the name. Current code renders the emoji instead. **Action:** Replace emoji with section number + decorative line.

2. **"The Police" / "The Creator" subtitle** — Screenshots show a clear subtitle line below the name in the agent's accent color. Current code has the nickname as a pill badge. **Action:** Add a subtitle line between name and badge, using the agent's display title.

3. **Role badge format** — Screenshot shows "• Admin" with a dot prefix inside a bordered pill. Current code matches this. ✓

4. **Code tag at bottom** — Screenshot shows `<admin role="coordinator" status="online" />` styled as a monospace code snippet. Current `RoleTag` component renders `<coordinator />` format. **Action:** Update to show full attribute syntax matching screenshots.

5. **Bottom label on image** — Screenshot 2 (Tyler) shows a "🔧 BUILDER" label at bottom of image frame. Not in current code. **Action:** Add role label bar at bottom of image container.

---

## Required Changes

### 1. Add `subtitle` field to Agent data

```ts
// lib/agents.ts — add to Agent interface
subtitle: string;

// Values:
// Popo: "The Police"
// Tyler: "The Creator"  
// Kanye: "The Thinker"
// Rocky: "The Gatekeeper"
```

### 2. Replace emoji with section number + line

In `AgentText`, replace the emoji block with:

```
<span className="font-mono text-sm tracking-widest" style={{ color: agent.primary, opacity: 0.6 }}>
  {String(index + 1).padStart(2, '0')}
</span>
<span className="inline-block ml-3 h-px w-12" style={{ backgroundColor: agent.primary, opacity: 0.4 }} />
```

### 3. Add subtitle below name

After the `<h2>` name element, add:

```
<h3 className="font-display italic leading-none" 
    style={{ fontSize: 'clamp(2rem, 4.5vw, 4rem)', color: agent.primary }}>
  {agent.subtitle}
</h3>
```

### 4. Update RoleTag to full attribute syntax

Change from `<coordinator />` to `<admin role="coordinator" status="online" />`:

```
{`<${agent.name.toLowerCase()} role="${agent.role.toLowerCase()}" status="online" />`}
```

### 5. Add image bottom label

Add a small bar at the bottom of the image container:

```
<div className="absolute bottom-0 inset-x-0 z-20 flex items-center justify-center py-2 backdrop-blur-sm"
     style={{ backgroundColor: `rgba(${rgb}, 0.15)`, borderTop: `1px solid rgba(${rgb}, 0.3)` }}>
  <span className="font-mono text-xs uppercase tracking-widest" style={{ color: agent.primary }}>
    {agent.emoji} {agent.role.toUpperCase()}
  </span>
</div>
```

---

## What NOT to Change

- Agent order (Popo → Tyler → Kanye → Rocky) — intentional, approved by Gatekeeper
- Color palette — intentional creative deviation, approved
- Parallax, hover effects, scan line, glow — all stay
- DotNav, SectionSpotlight, vignette — all stay
- No other sections (Hero, Pipeline, Terminal, CTA, Footer) affected

---

## Summary

This is a **text layout refinement** — adding the section number header, subtitle line, fuller code tag syntax, and image role label to match the editorial design language Xiaosong approved in the screenshots. Structure and effects stay the same.

**Handoff to:** Creator 🎨 for implementation.
