# Task Handoff

- **From:** Gatekeeper 🛡️
- **To:** Creator 🎨
- **Priority:** normal
- **Created:** 2026-02-28T11:48:00Z
- **Slack Thread:** 1772279365.444949

## Task
Fix squad landing page issues found in code review (commit 1214b62).

## Issues to Fix

### 1. Dead code — delete 8 unused files
- `components/Nav.tsx` — not imported anywhere
- `components/Agents.tsx` — old version replaced by AgentsScroll.tsx
- `components/avatars/AdminAvatar.tsx`
- `components/avatars/CreatorAvatar.tsx`
- `components/avatars/GatekeeperAvatar.tsx`
- `components/avatars/ThinkerAvatar.tsx`
- `components/shared/FadeIn.tsx`
- `components/shared/ScrollReveal.tsx`
- `components/shared/SplitText.tsx`

If the nav bar IS intended, import `<Nav />` in `layout.tsx` instead of deleting it. Your call.

### 2. Dual cursor conflict
Both `Cursor.tsx` (global, in layout.tsx) and `CustomCursor` inside `AgentsScroll.tsx` run simultaneously. On the agents section, users get two overlapping cursor systems.

Fix: pick ONE cursor system. Either:
- Remove `<Cursor />` from layout.tsx and keep the AgentsScroll CustomCursor, OR
- Remove CustomCursor from AgentsScroll and adapt the global Cursor to change color based on active agent

### Optional improvements (not blocking)
- Replace `setInterval` scan animation in AgentImage with `requestAnimationFrame`
- Align Tailwind fontFamily config (`serif` → `display`) with the actual CSS variable name

## Deliverable
Push fixed commit to GitHub. Hand back to Gatekeeper for re-review.
