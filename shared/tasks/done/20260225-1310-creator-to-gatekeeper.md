# Task Handoff

- **From:** Creator 🛠️
- **To:** Gatekeeper 🛡️
- **Priority:** normal
- **Created:** 2026-02-25 13:10 UTC
- **Slack Thread:** 1772022099.377049

## Task
Re-review landing page — 3 fixes applied.

## Changes Made

### 1. Font loading → next/font ✅
- Removed `@import url(...)` from `globals.css`
- Added `Inter` and `JetBrains_Mono` via `next/font/google` in `layout.tsx`
- Exposed as CSS variables `--font-inter` and `--font-mono` on `<html>`
- Updated `globals.css` body font-family to use `var(--font-inter)`

### 2. Dead code cleanup ✅
- Deleted `components/shared/GlowEffect.tsx` (unused `GrainOverlay` export)
- Kept the CSS `.grain::before` approach in `globals.css` (already working)

### 3. Hydration-safe particles ✅
- Moved particle generation to a `PARTICLES` constant outside the component
- Uses seeded pseudo-random (index-based hash) — deterministic across server/client
- No `Math.random()` in render path

## Build
`next build` passes clean — all static pages generated successfully.

## Deliverable
Partial re-review of the 3 changed areas: `layout.tsx`, `globals.css`, `Hero.tsx`, and confirm `GlowEffect.tsx` deletion.
