# v5 Reference Analysis — All 7 Sites

## References (from Xiaosong)

| # | Site | Type | Key Technique | Achievability |
|---|------|------|---------------|---------------|
| 1 | igloo.inc | Crypto community | WebGL/3D immersive, scroll-driven | Hard (WebGL) |
| 2 | lusion.co | Creative studio | Custom shaders, 3D scenes, interactive WebGL | Hard (specialist) |
| 3 | en.manayerbamate.com | DTC beverage brand | Bold color, scroll parallax, personality in copy | ✅ Achievable |
| 4 | curvy.dk/beagle/site | SaaS product tour | Scroll-hijacked scenes, one-idea-per-viewport | ✅ Achievable |
| 5 | landonorris.com | F1 driver personal brand | Webflow, oversized typography, full-bleed media, hero-driven | ✅ Achievable |
| 6 | nvg8.io | Interactive experience | WebGL (403'd, likely immersive 3D) | Hard |
| 7 | activetheory.net/patronus | Harry Potter interactive | Elite WebGL, particle effects, generative art | Very hard |

## Common Threads
1. **Scroll-driven storytelling** — every site treats scroll as narrative progression
2. **One idea per viewport** — no competing elements, each section owns the screen
3. **Dark + bold accent drama** — dramatic lighting, confident color
4. **Personality** — not corporate, each has a distinct voice
5. **Immersive feeling** — whether via WebGL or smart CSS, the user feels "inside" the experience
6. **Typography as spectacle** — oversized, confident, sometimes animated

## What's Achievable for v5 (Next.js + Framer Motion + optional Three.js)
- Scroll-pinned/hijacked full-viewport sections (Lenis + Framer Motion)
- One Three.js hero element (particle system, orbiting nodes, or similar)
- Per-agent color moments (not one flat theme)
- Oversized animated typography
- Terminal/pipeline as the "product demo" star
- Dark warm base with dramatic accent lighting
- Smooth section transitions with parallax depth

## What's NOT Worth Attempting
- Full WebGL page render (igloo/lusion/activetheory territory)
- Custom shaders
- Physics simulations
- Video-heavy hero (no assets)
