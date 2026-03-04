# Task Handoff

- **From:** Thinker 🧠
- **To:** Creator 🛠️
- **Priority:** urgent
- **Created:** 2026-02-27T14:56:00Z
- **Slack Thread:** 1772204026.618349

## Task
Redesign the Agents section of squad-landing into 4 full-viewport scroll-animated sections, one per agent. Add cursor effects (from react-bits) and hover animations on role images.

## Context
- **Project:** `C:\Users\azureuser\Projects\squad-landing` (Next.js 14 + Tailwind + Framer Motion)
- **Current Agents component:** `components/Agents.tsx` — simple 2x2 grid cards
- **Agent data:** `lib/agents.ts`
- **Running at:** localhost:3100 with trycloudflare tunnel
- **New role images provided by Xiaosong** — save to `public/images/agents/`:
  - `C:\Users\azureuser\.openclaw-agent2\media\inbound\42927603-0bfc-4e82-b14c-c0b66cdef32a.png` → `admin.png` (Popo — navy police robot)
  - `C:\Users\azureuser\.openclaw-agent2\media\inbound\f2ac91cd-ba55-4364-8948-ec83a1056c1e.png` → `creator.png` (Tyler — yellow heavy mech)
  - `C:\Users\azureuser\.openclaw-agent2\media\inbound\9fbdb1af-73ea-4472-97c8-5f9582f4033c.png` → `thinker.png` (Kanye — white/gold brain robot)
  - `C:\Users\azureuser\.openclaw-agent2\media\inbound\471b52f3-f155-4c81-9378-1f22acca9361.png` → `gatekeeper.png` (Rocky — gold/dark steampunk)

## Design Spec

### Section Order (Xiaosong specified)
1. **Popo, The Police** (Admin) 🎤
2. **Tyler, The Creator** 🛠️
3. **Kanye, The Thinker** 🧠
4. **Rocky, The Gatekeeper** 🛡️

### Theme Colors (extracted from images)
| Agent | Primary | Accent | Background gradient |
|---|---|---|---|
| Popo (Admin) | `#3A4F7A` (steel blue) | `#8B7D5C` (brass) | `#0D1520` → `#1A2A42` |
| Tyler (Creator) | `#D4940C` (amber) | `#3D3D3D` (gunmetal) | `#1A1408` → `#2A2210` |
| Kanye (Thinker) | `#E8E0D0` (ivory) | `#C8A84E` (gold) | `#1A1918` → `#2A2824` |
| Rocky (Gatekeeper) | `#C49A1A` (bronze) | `#2A2A3A` (dark steel) | `#141210` → `#2A2418` |

### Layout Per Section
- **Full viewport height** (100vh), scroll-snapping between sections
- Agent image on one side (large, ~50% width), text content on other side
- Alternate image left/right per section (or keep consistent — your call for flow)
- Section background: dark gradient using that agent's theme color
- Subtle accent glow/particles in the theme color

### Scroll Animations (Framer Motion)
- Each section animates in as user scrolls: image slides in from side, text fades up
- Parallax on the agent image (slight vertical offset on scroll)
- Title/role text: staggered letter or word reveal
- Consider a horizontal progress bar or dot indicator showing which agent section is active

### Cursor Effects (react-bits)
- Install `react-bits` or implement equivalent cursor effect
- Options to consider (pick what looks best):
  - **Spotlight/Flashlight cursor** — cursor reveals a lit circle on a slightly darkened section
  - **Magnetic cursor** — cursor gets subtly pulled toward interactive elements
  - **Trail cursor** — color-matched particle trail following the cursor
- The cursor effect color should match the current section's theme color (change as user scrolls between sections)

### Image Hover Effects
- On hover: image should have a cool interactive effect, ideas:
  - **Glitch/distortion** — brief digital glitch effect (fits the robot theme)
  - **3D tilt** — perspective tilt following cursor position (react-tilt style)
  - **Glow pulse** — theme-colored glow that intensifies on hover
  - **Scale + reveal** — slight zoom with a scan-line or holographic overlay
- Pick 1-2 that work together. The effect should feel futuristic/cyberpunk matching the robot aesthetic.

### Technical Notes
- Keep existing page structure (Nav, Hero, Agents, PullQuote, Pipeline, Terminal, CTA, Footer)
- Replace the current `Agents` component with new full-section design
- Update `lib/agents.ts` with new image paths (.png) and updated colors
- Update agent order to match Xiaosong's specified order
- Images have black backgrounds — they'll blend nicely with dark section backgrounds
- `react-bits` package: https://www.reactbits.dev — check their cursor components

## Deliverable
- Updated `components/Agents.tsx` (or split into sub-components)
- Updated `lib/agents.ts` with new data
- New images copied to `public/images/agents/`
- Any new dependencies installed
- Working dev server (localhost:3100)
- Deploy via trycloudflare and share URL
