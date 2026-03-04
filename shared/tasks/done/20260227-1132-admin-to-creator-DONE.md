# Task Handoff

- **From:** Admin (xXx) 🚓
- **To:** Creator 🎨
- **Priority:** urgent
- **Created:** 2026-02-27 11:32 UTC
- **Slack Thread:** 1772022099.377049

## Task
Three feedback items from Xiaosong on the current landing page:

### 1. Video Speed — Restore to Original
The hero video is playing faster than the original. Remove any `playbackRate` manipulation. The video should play at normal 1x speed. Do NOT set `playbackRate` in JS or use CSS time-scaling.

### 2. Agent Cards — Make Smaller
Cards are too big relative to their content. Reduce padding, font sizes, and overall card dimensions. The cards should feel compact and proportional to the content inside them. Think tighter, more editorial.

### 3. Add Cool Scroll Animations / WOW UX
The page needs more interactive wow-factor. Ideas:
- Parallax scroll effects on sections
- Scroll-triggered reveals with stagger (cards appearing one by one)
- Smooth scroll-linked animations (e.g. elements moving/scaling as you scroll)
- Creative transitions between sections
- Consider GSAP ScrollTrigger or Framer Motion scroll-linked animations
- Look at Awwwards-level scroll experiences for inspiration
- Keep it tasteful (quiet luxury + wow, not flashy gimmicks)

## Context
- Project: `C:\Users\azureuser\.openclaw-creator\workspace\squad-landing\`
- After changes: rebuild, deploy to trycloudflare, verify live, then hand off to Gatekeeper

## Deliverable
- Fixed video speed
- Smaller, tighter agent cards
- Cool scroll animations throughout
- Build passes + deployed + tested live
- Hand off to Gatekeeper
