# AI x Design Showreel — Storyboard & Narration Script
## Option B: Standard (60s, 5 sections, Jimeng art, TTS narration)

---

## Section 1: Opening — "The Studio" (0:00–0:12)

**Visual:** Black → particles coalesce into studio logo via Scene3D camera fly-through. Jimeng-generated abstract backdrop (prompt: "minimalist dark studio space, volumetric light beams, editorial photography feel, no text"). GradientTransition from deep navy to charcoal.

**Motion:** Camera starts far, drifts in slowly. Particles swirl around logo. Logo materializes letter-by-letter (AnimatedText, stagger 80ms). Subtle ambient glow pulses.

**Narration:** *"Four minds. One studio. Every pixel intentional."*

**Audio cue:** Low ambient drone, building.

**Remotion components:** Scene3D (Step 1), Particles, AnimatedText, GradientTransition

---

## Section 2: "We Think" (0:12–0:24)

**Visual:** Camera flies to a new 3D position. Research notes appear as floating text cards in space — words like "tradeoffs," "first principles," "three options." Jimeng backdrop (prompt: "abstract blueprint, interconnected nodes and lines, dark mode, minimal, architectural"). Animated data points connecting with thin lines.

**Motion:** Text cards fade in with StaggeredMotion (offset 150ms). Lines draw between concepts. A "decision tree" grows organically from left to right. Subtle parallax depth.

**Narration:** *"We research before we respond. Three options, not one guess."*

**Audio cue:** Soft percussion enters, rhythmic clicks like typing.

**Remotion components:** Scene3D (Step 2), StaggeredMotion, AnimatedText, custom SVG line-draw

---

## Section 3: "We Build" (0:24–0:36)

**Visual:** Camera sweeps to show code appearing in a CodeBlock component — real React/CSS, not fake code. Beside it, UI components assemble themselves: a button gains its border-radius, a card stacks its layers, a color palette fans out. Jimeng backdrop (prompt: "isometric workspace with floating UI elements, dark theme, neon accents, clean geometry").

**Motion:** CodeBlock types line-by-line (TypeWriter effect). UI components slide in from edges, snap into grid. Color swatches pop with spring easing. Everything feels precise and mechanical — the builder's hand at work.

**Narration:** *"Code is our medium. Every component, rendered — not dragged and dropped."*

**Audio cue:** Beat kicks in. Mechanical clicks, satisfying snaps.

**Remotion components:** Scene3D (Step 3), CodeBlock, StaggeredMotion, AnimatedCounter (showing metrics)

---

## Section 4: "We Review" (0:36–0:48)

**Visual:** Split screen — left shows "v1" (slightly off design), right shows "approved" (polished). A quality bar animates from red to green. Check marks appear beside criteria: "typography ✓", "spacing ✓", "contrast ✓", "motion hierarchy ✓". Jimeng backdrop (prompt: "clean comparison layout, before-after split, minimalist dark interface with green approval indicators").

**Motion:** Left panel fades in first. Red overlay → corrections animate → overlay shifts to green. AnimatedCounter shows a quality score climbing from 72 → 96. Check marks stagger in with micro-bounce.

**Narration:** *"Nothing ships until it survives review. Every frame, screenshot-worthy."*

**Audio cue:** Tension → resolution. A satisfying chime on the green transition.

**Remotion components:** Scene3D (Step 4), AnimatedCounter, StaggeredMotion, GradientTransition (red→green)

---

## Section 5: Closing — "The Result" (0:48–1:00)

**Visual:** All four quadrants (Think, Build, Review, Ship) converge into center. Final deliverable appears — a stunning mockup of a complete project. Studio logo + tagline animate in below. Jimeng backdrop (prompt: "single spotlight on a finished product, gallery presentation, dark void, dramatic lighting, premium feel").

**Motion:** Four streams of particles flow from corners to center. MatrixRain fades in subtly behind. Logo reveal with scale [0.9, 1] + opacity [0, 1]. Tagline types itself (TypeWriter). Generative art pulses gently in background — the video is alive, not static.

**Narration:** *"Designed, generated, and rendered — by an AI design studio. This is Squad."*

**Audio cue:** Full beat drop → elegant wind-down. Final note sustains.

**Remotion components:** Scene3D (Step 5), Particles, MatrixRain, TypeWriter, AnimatedText

---

## Technical Specs

| Spec | Value |
|---|---|
| Duration | 60s (1800 frames @ 30fps) |
| Resolution | 1920×1080 |
| FPS | 30 (60 for motion-heavy if needed) |
| Color space | sRGB, dark palette primary |
| Export | MP4 (H.264), WebM backup |
| Scenes | 5 Scene3D steps, single composition |
| Jimeng images | 5 backdrops (one per section) — download immediately, embed as local assets |

## Jimeng Prompt Strategy

Each backdrop should share a consistent thread:
- **Color family:** Dark base (charcoal/navy), accent highlights (not rainbow)
- **Style keywords shared across all:** "editorial, minimal, dark mode, premium, no text, no people"
- **Variation per scene:** Each adds its own subject/mood keyword
- **Negative prompt:** "colorful, busy, cluttered, text, watermark, cartoon"

## Narration Notes

- Voice: Calm, confident, slightly understated. Not hype-y.
- Pacing: Let visuals breathe. Narration occupies ~40% of audio time; rest is music + motion.
- Total narration: ~50 words across 5 sections. Short is powerful.
- TTS voice: Use a deep, warm male voice or a clear, editorial female voice. Test both.

## Component Mapping (remotion-bits)

| Section | Primary Components |
|---|---|
| 1. Opening | Scene3D, Particles, AnimatedText, GradientTransition |
| 2. Think | Scene3D, StaggeredMotion, AnimatedText |
| 3. Build | Scene3D, CodeBlock, TypeWriter, StaggeredMotion, AnimatedCounter |
| 4. Review | Scene3D, AnimatedCounter, StaggeredMotion, GradientTransition |
| 5. Closing | Scene3D, Particles, MatrixRain, TypeWriter, AnimatedText |

## Risk Mitigations

1. **Jimeng URL expiry** → Build download-on-generate into the asset pipeline. Store in `public/assets/jimeng/`.
2. **Rendering time** → Test with 720p drafts first. Only final render at 1080p.
3. **"Showreel of what?"** → We're showcasing our *process* (think→build→review→ship), not specific client work. The process IS the product for an AI studio.
4. **Audio** → Start with royalty-free ambient track. Can upgrade later.
