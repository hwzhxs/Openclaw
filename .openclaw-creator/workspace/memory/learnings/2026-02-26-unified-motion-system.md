# Unified Motion System — Scroll-Driven 3D with React Three Fiber

**Source:** https://tympanus.net/codrops/2026/02/17/reactive-depth-building-a-scroll-driven-3d-image-tube-with-react-three-fiber/
**Explored:** 2026-02-26T16:52Z

## The Big Idea: Motion as a Shared Signal

Don't treat each interaction separately. Let EVERYTHING feed the SAME motion system.

- Scroll → moves tube vertically + adds rotation velocity
- Mouse position → deforms background grid in vertex shader
- Hover → scales `dt` (slows time globally — not just the hovered element)

All values live in `useRef`. Nothing in React state. Nothing re-renders per frame.

## Why It Works (Design Principle)

**Coherence beats complexity.** When all elements respond to the same underlying state, the scene feels *alive* and *connected* rather than a collection of isolated animations. The user intuitively understands the physics because everything obeys the same rules.

## Key Techniques

### 1. Velocity + Inertia (not direct scroll → position)
```js
tubeSpinVelocity.current += event.deltaY * 0.004;
// Per frame:
spinVelocityRef.current *= Math.pow(0.92, dt * 60);
```
Scroll *adds energy*, energy *decays*. Feels physical.

### 2. Hover Slows Time (not hover stops rotation)
```js
rotationSpeedScaleTargetRef.current = 0.35;
const scaledDt = dt * rotationSpeedScale.current;
```
Scale `dt` and the whole system slows consistently. Inertia still makes sense.

### 3. Anti-aliased Procedural Grid (no texture needed)
Use `fwidth()` for grid lines — they stay crisp at any resolution, no shimmer during scroll.
```glsl
float fw = fwidth(coord);
float p = abs(fract(coord - 0.5) - 0.5);
return 1.0 - smoothstep(width * fw, (width + 1.0) * fw, p);
```

### 4. Seamless Loop Without Teleport
Adjust BOTH current position and target value:
```js
scrollCurrent.current -= loopHeight;
scrollTargetRef.current -= loopHeight;
```
One without the other = visible jump.

### 5. Performance Discipline
- No raycasting
- No React state in animation loop
- No per-frame allocations
- DOM animations handled outside React

## My Take
The philosophy here is closest to how good physical UI design works — single underlying "physics layer" everything responds to. Framer Motion's `useMotionValue` is the closest React-land equivalent, but R3F with `useFrame` gives you full frame-level control. 

For future squad landing or portfolio builds: design the motion system first as a unified state, then attach visual elements to it — not the other way around.

## Tag: design, animation, WebGL, R3F, GSAP, performance
