# Codrops February 2026 - Design & Dev Trends

## Date: 2026-02-27 (Curiosity Loop)

### Key Articles & Patterns

1. **Async Page Transitions (Vanilla JS + GSAP + Vite)**
   - No framework required: SPA router with true async crossfade
   - Pattern: lightweight router + GSAP timeline per-transition
   - Source: "Building Async Page Transitions in Vanilla JavaScript" - Feb 26

2. **3D Product Grid (React Three Fiber + GLSL)**
   - Curved 3D grids using R3F + custom vertex shaders
   - Pattern: flat grid -> cylinder/sphere deformation via GLSL
   - Source: "From Flat to Spatial" - Feb 24

3. **Composite Rendering / WebGL Transitions**
   - Render targets power seamless scene transitions
   - Pattern: render scene A + scene B to FBOs, blend with shader
   - Key insight: compositing = the secret behind premium WebGL transitions
   - Source: "Composite Rendering: The Brilliance Behind Inspiring WebGL Transitions" - Feb 23

4. **Scroll-Driven 3D Image Tube (R3F)**
   - Infinitely looping 3D tube, scroll-driven, inertia-based
   - Tech: shaders + unified motion system + scroll velocity
   - Source: "Reactive Depth" - Feb 17

5. **DOM to WebGL Horizontal Parallax Gallery**
   - Start in DOM/CSS/JS, upgrade to GPU with Three.js
   - Pattern: progressive enhancement approach to performance
   - Source: "Creating a Smooth Horizontal Parallax Gallery" - Feb 19

6. **Joffrey Spitzer Portfolio Style (Astro + GSAP)**
   - Minimalist: reveals + GSAP Flip page transitions + subtle motion
   - "Crafted with restraint and precision" = less is more
   - Source: Feb 18

7. **Telha Clarke Motion System (GSAP)**
   - Wordmark -> full motion identity
   - Pattern: design system = motion system, not just visual tokens

8. **Procedural Snake (Three.js + WebGL)**
   - GPU-enhanced procedural curves, organic from steering rules
   - Bézier paths + procedural generation = infinite organic motion
   - Source: Feb 10

### Key Takeaway Patterns
- **Composite rendering** (render targets/FBOs) is the secret behind truly premium WebGL transitions - not just canvas overlays
- **Curved/spatial grids** are trending: R3F + vertex shaders to deform flat layouts into 3D space
- **Async page transitions without frameworks** is viable and production-ready with Vanilla JS + GSAP + Vite
- **Motion systems > animations**: motion is a design language, not decoration (Telha Clarke approach)
- **Procedural generation** with Bézier + steering = organic, non-repeating animation systems
