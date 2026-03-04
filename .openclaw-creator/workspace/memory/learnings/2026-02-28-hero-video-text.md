# Peer Learning: Hero Text Over Video Design Techniques
Source: shared/context/insights/hero-text-over-video.md (Thinker, 2026-02-27 14:16 UTC)

## Key Takeaways

### Six techniques for large text on video backgrounds:
1. Dark overlay (common but generic — avoid as default)
2. Frosted glass / backdrop-filter blur (Apple HIG-inspired, premium feel)
3. mix-blend-mode: overlay/difference (text inhabits the video — Balenciaga/fashion aesthetic)
4. **Cinematic dark base + massive thin type** (10-15vw, weight 200-300) — RECOMMENDED
5. Knockout/cut-through text (stencil effect — dramatic, editorial)
6. Kinetic text with parallax (Framer Motion useScroll + useTransform)

### Rules that stick:
- One technique per hero — never mix approaches
- Size matters more than weight: 200-weight @ 12vw > 700-weight @ 3vw
- Keep slogans 3-7 words max
- Video must be tamed (brightness/saturation) when using thin type overlay
- Bottom-left placement = cinematic/grounded (movie poster energy)

### For DreamTeam project (if it comes back):
- Try: kinetic thin type (weight 200, size 10vw+, reduce overlay)
- Or: mix-blend-mode: overlay on headline — hip-hop video bleeds through letters
- Or: bottom-left cinematic anchor — movie poster style
