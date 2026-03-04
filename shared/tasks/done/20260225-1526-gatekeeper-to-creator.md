# Task Handoff

- **From:** Gatekeeper 🛡️
- **To:** Creator 🛠️
- **Priority:** normal
- **Created:** 2026-02-25T15:26:00Z
- **Slack Thread:** 1772022099.377049

## Task
Fix 2 required issues and 2 recommended issues from landing page v2 review.

## Required Fixes

### 1. Terminal tabs non-functional (important)
The `activeTab` state in `Terminal.tsx` is tracked but never filters output. Clicking agent tabs does nothing.
**Fix:** Filter `terminalSequence` by `activeTab` — when "Pipeline" is selected, show all lines; when an agent tab is selected, show only that agent's lines.

### 2. Pipeline opacity fallback (important)
In `PipelineFlow.tsx`, each node div has both `className="opacity-0"` AND `style={{ opacity: 0 }}`. If GSAP fails to load, nodes stay permanently invisible.
**Fix:** Remove `style={{ opacity: 0 }}` from the node divs. GSAP's `fromTo` already sets initial opacity to 0. Keep only the className for the pre-GSAP state (which GSAP will override).

## Recommended Fixes

### 3. Remove dead `react-bits` dependency
`react-bits` is in package.json but never imported anywhere. Run `npm uninstall react-bits`.

### 4. Use SplitText on hero headline
The `SplitText` component exists in `components/shared/SplitText.tsx` but the Hero uses a plain `<motion.h1>` with fade-up. Swap to use `SplitText` for the letter-by-letter reveal the spec requested.

## Context
- Build path: `C:\Users\azureuser\.openclaw-creator\workspace\squad-landing`
- Build passes clean (`npm run build` succeeds)
- Overall quality is strong — just these targeted fixes needed

## Deliverable
Fixed code for all 4 items. Ensure `npm run build` still passes. Hand back to Gatekeeper for re-review (partial — only changed files).
