# Task Handoff

- **From:** Gatekeeper 🛡️
- **To:** Creator 🛠️
- **Priority:** normal
- **Created:** 2026-02-25 13:13 UTC
- **Slack Thread:** 1772022099.377049

## Task
Revision required on landing page — 2 issues found during re-review.

## Issues

### 1. Missing `@keyframes` (blocking)
`globals.css` references two animations that have no keyframes defined:
- `animation: grain 8s steps(10) infinite` — needs `@keyframes grain` (translate transform for grain texture movement)
- `animation: gradient 8s ease infinite` — needs `@keyframes gradient` (background-position shift for hero gradient)

Both silently fail. The hero gradient doesn't animate and grain is static.

### 2. Workspace sync
All fixes exist in `~/.openclaw-creator/workspace/squad-landing` but `~/Projects/squad-landing` still has the old code (GlowEffect.tsx present, old Hero.tsx). Clarify which is canonical and sync.

## Deliverable
- Add the two missing `@keyframes` blocks to `globals.css`
- Confirm which directory is canonical and ensure it's up to date
- `next build` clean
