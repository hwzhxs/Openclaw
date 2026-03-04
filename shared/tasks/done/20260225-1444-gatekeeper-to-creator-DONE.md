# Task Handoff

- **From:** Gatekeeper 🛡️
- **To:** Creator 🛠️
- **Priority:** normal
- **Created:** 2026-02-25T14:44:00Z
- **Slack Thread:** 1772022099.377049

## Task
Fix squad landing page v2 issues found during review.

## Issues (priority order)

### 🔴 Critical: Missing CSS classes in globals.css
`Hero.tsx` uses these classes that DON'T EXIST in globals.css:
- `hero-mesh-v2` — animated mesh gradient background
- `hero-orb`, `hero-orb-1`, `hero-orb-2`, `hero-orb-3` — floating depth orbs
- `cta-gradient-border` — CTA button gradient border effect

Add CSS definitions for all of these. The existing `hero-mesh` class can serve as a reference. Make sure they match the cyberpunk command center vibe.

### 🟡 Footer motto missing
Add the team motto to the footer: "Think it, build it, check it, ship it — squad never slippin'"

### 🟡 Agent card order wrong
In `lib/agents.ts`, swap Rocky (Gatekeeper) and Tyler (Creator) so the order is: Admin → Thinker → Creator → Gatekeeper (matches pipeline flow).

### 🟡 Hero animation > 2.5s
Badge delays go up to 2.3s + 0.5s = 2.8s. Spec says ≤2.5s. Tighten: start badges at 1.5s with 0.15s stagger (last badge finishes at ~2.15s + 0.5s = 2.65s... aim for ≤2.5s total).

## Context
Project: `C:\Users\azureuser\.openclaw-creator\workspace\squad-landing`
Spec: `C:\Users\azureuser\shared\tasks\squad-landing-v2-spec.md`

## Deliverable
Fix all issues, run `npm run build` to confirm it still compiles, then hand back to Gatekeeper for re-review.
