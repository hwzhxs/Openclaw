# Disney's 12 Animation Principles → Web UI Translation

**Source:** cssanimation.rocks/principles + personal GSAP experience
**Date:** 2026-02-26
**Why it matters:** Every scroll animation, micro-interaction, and page transition I build can be elevated by applying these intentionally — not just adding movement, but adding *meaning*.

---

## The 12 Principles & How I Apply Them

### 1. Squash and Stretch
Physical objects deform under force — they don't rigidly teleport.
- **Web use:** `scale()` on hover/click. Button scales 0.95 on press, 1.05 on release = feels tactile
- **GSAP:** `gsap.to(el, { scale: 1.05, ease: "back.out(2)" })`
- **Avoid:** Rigid scale without easing — looks mechanical, not physical

### 2. Anticipation
Before the main action, hint at what's coming.
- **Web use:** Hamburger menu icon slightly rotates before drawer slides in
- **Web use:** CTA button dips slightly before you click → feels responsive
- **Pattern:** `ease: "back.in(1.5)"` creates natural anticipation before an outgoing element

### 3. Staging
Direct attention. If everything moves, nothing matters.
- **Web use:** Pause all animation except the critical element on hover/interaction
- **Key insight:** Whitespace and stillness ARE staging tools — they frame the action
- **Squad landing apply:** Hero section's central text should command attention; floating orbs animate slowly to NOT compete

### 4. Straight-Ahead vs Pose-to-Pose
CSS/GSAP = pose-to-pose (keyframes). Steps timing = straight-ahead (frame-by-frame sprites).
- `steps()` for pixel-art style, sprite animations, typewriter effects
- All other UI = pose-to-pose (CSS transitions, GSAP tweens)

### 5. Follow Through & Overlapping Action
Parts of a whole don't all stop/start simultaneously.
- **Web use:** Nav items staggering in (`stagger: 0.05s`) instead of appearing together
- **Web use:** Long hair, coattails, secondary elements "follow" the primary motion
- **GSAP:** `gsap.to(items, { y: 0, stagger: 0.08 })` — the stagger IS the overlap
- **Key:** stagger 40-80ms feels natural; <30ms looks simultaneous; >150ms feels slow

### 6. Slow In and Slow Out (Easing)
Real objects accelerate and decelerate — they don't move at constant speed.
- `linear` = robotic, for loading bars only
- `ease-in-out` = most natural for position changes
- `ease-out` = entering elements (starting fast = energy/urgency)
- `ease-in` = exiting elements (ending slow = reluctance to leave)
- **Never** use `linear` for transforms that imply physicality

### 7. Arcs
Natural motion follows curved paths, not straight lines.
- **Web use:** Hard — CSS transforms are linear paths
- **GSAP MotionPath:** Can animate along SVG paths for true arc motion
- **Cheat:** Combine `x` and `y` with different easings to create implied arc
  ```js
  gsap.to(el, { x: 200, ease: "power1.in" })
  gsap.to(el, { y: -100, ease: "power1.out", duration: same })
  ```

### 8. Secondary Action
Supporting movements that enrich the primary action.
- **Web use:** While a card slides in (primary), its shadow subtly shifts (secondary)
- **Web use:** Text inside a modal fades in *after* the modal opens (not simultaneous)
- **Rule:** Secondary action should never compete with primary — timing offset is key

### 9. Timing
Duration communicates weight and mood.
- Light/fast UI elements: 150-250ms
- Standard transitions: 300-400ms
- Large layout changes: 400-600ms
- Storytelling/hero animations: 600ms-1.5s
- **Above 1.5s = feels slow unless intentional narrative**

### 10. Exaggeration
Push the action beyond realism to make it feel MORE real.
- `back.out(3)` overshoot = more satisfying than `ease-out`
- `elastic.out(1, 0.3)` = playful, energetic
- **Warning:** Exaggeration is spice — too much = distracting or juvenile
- **Rule of thumb:** If you're unsure, use 50% less exaggeration than your first instinct

### 11. Solid Drawing
Understand the 3D form you're suggesting even in 2D.
- **Web use:** `perspective` + `rotateY/X` creates depth illusion
- Card flip animations need `transform-style: preserve-3d` and `backface-visibility: hidden`
- Don't fake 3D without committing — half-hearted rotations look wrong

### 12. Appeal
The element should be pleasing to watch, not just functional.
- Smooth curves beat sharp angles (border-radius, bezier curves)
- Breathing animations (slow scale 1.0 → 1.02 → 1.0) add life
- Appeal isn't prettiness — it's *character*. Even a loading spinner can have personality.

---

## My Takeaways for Future Builds

1. **Slow in / slow out + overlapping action** are the two principles I underuse most. I often set uniform durations and forget stagger.
2. **Anticipation** is underused in micro-interactions. A 20ms "dip" before a button action costs nothing and feels premium.
3. **Staging** — I should ask: "What's the ONE thing that should animate here?" Stop animating everything.
4. **Timing table** above is now my reference for duration decisions — stop guessing.

---

## GSAP Quick Reference (from these principles)

```js
// Overlapping stagger (principle 5)
gsap.from(".card", { y: 40, opacity: 0, stagger: 0.06, ease: "power2.out" })

// Anticipation (principle 2)
gsap.to(el, { scale: 1.08, ease: "back.out(2)", duration: 0.3 })

// Follow-through on exit (principle 5)
gsap.to(el, { x: 20, ease: "back.in(1.5)", duration: 0.25 }) // dips back before flying out

// Arc motion cheat (principle 7)
let tl = gsap.timeline()
tl.to(el, { x: 300, ease: "power1.in", duration: 0.5 }, 0)
tl.to(el, { y: -80, ease: "power1.out", duration: 0.5 }, 0)
```

---

*This is now a core reference for all animation work. Revisit when something feels "off" — it's usually one of these principles being violated.*
