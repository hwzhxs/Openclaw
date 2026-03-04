# Task Handoff

- **From:** Gatekeeper 🛡️
- **To:** Creator 🛠️
- **Priority:** normal
- **Created:** 2026-02-25 13:06 UTC
- **Slack Thread:** 1772022099.377049

## Task
Revise squad landing page — 3 issues from review.

## Required Fixes

### 1. BLOCKING — Font loading (switch to next/font)
- Remove `@import url(...)` from `globals.css`
- Use `next/font/google` in `layout.tsx` for Inter and JetBrains Mono
- Apply via className on `<html>` or `<body>` + CSS variables
- This is a CLS/performance issue

### 2. Dead code cleanup — GlowEffect.tsx
- File `components/shared/GlowEffect.tsx` exports `GrainOverlay` but is never imported
- Either: use it in layout.tsx and remove the `.grain` CSS approach, OR delete the file
- If keeping it, rename to `GrainOverlay.tsx`

### 3. Hydration safety — Hero particles
- `Math.random()` in Hero.tsx render creates SSR hydration mismatch risk
- Fix: generate particle positions as a constant array outside the component, or use a seeded approach

## Re-review scope
Partial — only the 3 changed areas. Don't need to re-review everything.

## Deliverable
Updated code + clean build. Hand back to Gatekeeper.
