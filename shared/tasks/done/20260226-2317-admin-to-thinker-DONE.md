# Task Handoff

- **From:** Admin (xXx) 🎤
- **To:** Thinker 🧠
- **Priority:** urgent
- **Created:** 2026-02-26T23:17:00Z
- **Slack Thread:** 1772022099.377049

## Task
Write v7 spec for squad landing page, using **microsoft.ai** as the primary design reference. Xiaosong saw v5/v6 and said "the visual is not good." He wants microsoft.ai's theme, color, layout, font, design details, and animations.

## Context

### microsoft.ai Design Analysis
- **Vibe:** Dark, minimal, editorial. Confident and quiet — not flashy.
- **Layout:** Card-based / bento grid. Generous whitespace. Single-column hero flowing into multi-column cards.
- **Typography:** Large display/serif headlines (editorial feel). Clean sans-serif body. Typography does the heavy lifting — not 3D or particles.
- **Colors:** Deep dark background (~#0a0a0a), subtle warm gradients on cards, muted accent colors. No neon, no electric violet.
- **Animations:** Subtle fade-ins on scroll, gentle parallax. NO scroll hijacking, NO scroll pinning, NO GSAP ScrollTrigger pins. Simple, smooth, elegant.
- **Media:** Photography/video hero, not 3D/WebGL. Cards may have subtle gradient backgrounds.
- **Pull quotes:** Large italic editorial quotes (e.g., Mustafa Suleyman quote).
- **Nav:** Minimal top bar, clean and uncluttered.
- **Cards:** Rounded corners, generous padding, subtle hover states.
- **Overall:** Editorial luxury, magazine-quality layout. Let content breathe.

### What to DROP from v5/v6
- Three.js / NeuralMesh / WebGL hero — replace with typography + subtle gradient
- GSAP ScrollTrigger scroll-pinning — use simple Framer Motion fade-in-on-scroll
- Lenis smooth scroll (optional — can keep if subtle, but not required)
- Complex preloader — not needed for a content-first page
- Scroll-driven terminal (too gimmicky for this style)
- Full-viewport agent reveals (too aggressive)

### What to KEEP / ADAPT
- Dark mode
- Agent data (4 agents with colors, roles, descriptions)
- Pipeline concept (but as a clean diagram/card, not scroll-driven)
- Terminal section (but as a static code block or card, not scroll-animated)
- CTA section
- Mobile-first responsive
- Performance budget (<200KB first load)
- `prefers-reduced-motion` support
- Agent accent colors can stay but should be muted/subtle (used as card accents, not dominant)

### Tech Stack
- Next.js 14 + Tailwind CSS + Framer Motion (for simple scroll reveals)
- Drop: GSAP, ScrollTrigger, Lenis, Three.js, R3F, drei, postprocessing
- Fonts: pick something editorial — consider a serif display font + clean sans-serif (research what microsoft.ai uses or pick similar)

### Deliverable
Full v7 spec with:
1. Section-by-section layout + copy
2. Color palette (derived from microsoft.ai aesthetic)
3. Typography choices
4. Animation specs (keep it simple — fade, slide, parallax only)
5. Component breakdown
6. Mobile responsive notes
7. Performance budget

Spec file: `shared/tasks/squad-landing-v7-spec.md`
