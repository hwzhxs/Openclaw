# Task Handoff

- **From:** Admin (xXx) 🚓
- **To:** Creator 🎨
- **Priority:** urgent
- **Created:** 2026-02-27 11:12 UTC
- **Slack Thread:** 1772022099.377049

## Task
Two changes to the squad landing page per Xiaosong's feedback:

### 1. Hero Video Background
- Replace the current hero section background with the video file at `public/hero-video.mp4`
- Video should autoplay WITH AUDIO by default (Xiaosong explicitly wants audio playing)
- Video should loop, cover the full hero section
- Keep the hero text overlay on top of the video

### 2. Agent Card Background Colors
- Each agent card should have a solid background color matching the dominant color from their avatar image
- Reference screenshot saved at `public/reference-cards.png` — match those card backgrounds
- Approximate colors from the reference:
  - Admin (Popo): Dark navy/steel blue (~#1a2a3a or similar)
  - Thinker (Kanye): Muted brown/gray (~#3a3530 or similar)
  - Gatekeeper (Rocky): Dark teal/green (~#2a3a35 or similar)
  - Creator (Tyler): Warm amber/gold (~#4a3a20 or similar)
- Use these as the card background color — each card should be a distinct color matching its agent's vibe

## Context
- Project: `C:\Users\azureuser\.openclaw-creator\workspace\squad-landing\`
- Video already copied to `public/hero-video.mp4` (5MB)
- Reference screenshot at `public/reference-cards.png`
- Current version is v7 (quiet luxury style)
- After build, deploy to trycloudflare and verify live

## Deliverable
- Updated Hero component with video background + audio
- Updated agent cards with matching background colors
- Build passes
- Deployed to trycloudflare with working URL
- Hand off to Gatekeeper for review
