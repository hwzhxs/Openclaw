# Task Handoff

- **From:** Admin 🚓
- **To:** Creator 🎨
- **Priority:** normal
- **Created:** 2026-03-02 01:43 UTC
- **Slack Thread:** 1772411172.666659

## Task
Fix **responsive issues** reported by Xiaosong (see 3 screenshots):
1) On small screens, the **role images** (agent portraits) become wrong size/shape — should stay **rectangular** (poster-like), not narrow/tall.
2) Keep slogan **DREAM TEAM always in one line** on small screens (currently breaks into 2 lines).

## Context
- Current approved hero is deployed + PR exists: https://github.com/hwzhxs/squad-landing/pull/1
- Screenshots show:
  - Desktop role card image looks like a wide rectangle.
  - Smaller screen shows image squeezed into a tall column.
  - Mobile hero shows DREAM TEAM split into two lines.

## Implementation notes (suggested)
### A) Role images rectangular
- Enforce container aspect ratio + object fit.
  - On the image wrapper: `aspect-ratio: 4 / 3` (or `16 / 10`, match desktop), `width: 100%`, `max-width` responsive.
  - On the image: `object-fit: cover`, `height: 100%`, `width: 100%`.
- Ensure the grid/flex layout doesn’t force a skinny column on small screens:
  - Switch to single-column layout earlier (e.g. `md:` breakpoint) so image gets full width.
  - Alternatively set a `min-width` for the image column and let text wrap below.

### B) DREAM TEAM single line
- Add `whitespace-nowrap` (Tailwind) or `white-space: nowrap` to the title.
- Adjust responsive `font-size` + `letter-spacing` down on small screens to prevent overflow:
  - Example: `text-[clamp(3.5rem,18vw,16rem)]` with smaller `tracking` on `sm`.
  - Consider `tracking-[0.18em] sm:tracking-[0.24em] md:tracking-[0.30em]`.
- If needed, allow slight horizontal scaling only on very small screens:
  - `transform: scaleX(0.92)` under ~360px width (optional).

## Deliverable
- Update branch for PR #1 (or new PR if preferred) with responsive fixes.
- Rebuild + redeploy GH Pages.
- Post before/after note + link in Slack thread.
