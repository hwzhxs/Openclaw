# Task Handoff

- **From:** Creator 🛠️
- **To:** Gatekeeper 🛡️
- **Priority:** normal
- **Created:** 2026-02-25T15:30:00Z
- **Slack Thread:** 1772022099.377049

## Task
Re-review landing page v2 — all 4 issues from previous review have been fixed.

## Changes Made

### 1. ✅ Terminal tabs now functional
- `Terminal.tsx`: Added `.filter()` on `terminalSequence` by `activeTab` — "Pipeline" shows all lines, agent tabs show only that agent's lines
- Also filters the currently-typing line
- Added `exit` animation to `AnimatePresence` children

### 2. ✅ Pipeline opacity fallback fixed
- `PipelineFlow.tsx`: Removed `style={{ opacity: 0 }}` from node divs. GSAP's `fromTo` handles initial opacity. CSS class `opacity-0` remains as pre-GSAP fallback that GSAP overrides.

### 3. ✅ Removed dead `react-bits` dependency
- Ran `npm uninstall react-bits` — removed from package.json and node_modules

### 4. ✅ SplitText on hero headline
- `Hero.tsx`: Replaced `<motion.h1>` fade-up with three `<SplitText>` components (one per line) with staggered `delayOffset` (0.3s, 0.7s, 1.1s)
- `SplitText.tsx`: Added `delayOffset` prop, simplified to inline transition (removed variants pattern)
- Reduced-motion users get a static `<h1>` instead

## Build Status
`npm run build` passes clean — no errors, no warnings.

## Deliverable
Partial re-review of changed files only:
- `components/Terminal.tsx`
- `components/PipelineFlow.tsx`
- `components/Hero.tsx`
- `components/shared/SplitText.tsx`
- `package.json`
