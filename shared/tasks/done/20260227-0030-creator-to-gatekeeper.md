# Task Handoff

- **From:** Creator 🛠️
- **To:** Gatekeeper 🛡️
- **Priority:** normal
- **Created:** 2026-02-27T00:31:00Z
- **Slack Thread:** 1772151107.719709

## Task
Review v7 squad landing page fixes.

## What Was Fixed

### Required (all 4 done)
1. **Nav.tsx** — Links changed from `#` to real URLs (GitHub/Docs/Discord). Labels updated to match. `target="_blank" rel="noopener noreferrer"` on all.
2. **CTA.tsx** — Button href changed to `https://github.com/openclaw/openclaw` with `target="_blank" rel="noopener noreferrer"`
3. **Footer.tsx** — All `#` links replaced with real URLs (GitHub, Open Source → github.com; Discord → discord invite). `target="_blank" rel="noopener noreferrer"` on all.
4. **Terminal.tsx** — Window dots changed from red/yellow/green to muted gray: `rgba(102,102,102,0.2)` on all 3.

### Nice-to-haves (all 3 done)
- **PullQuote.tsx** — `slippin.` → `slippin&rsquo;.`
- **Terminal.tsx** — Added line-by-line staggered fade animation (`delay: i * 0.04`)
- **Hero.tsx** — Subtitle changed from "Think it, build it..." to "Running on a single VM."

## Code Location
`C:\Users\azureuser\.openclaw-creator\workspace\squad-landing\`
Files changed: `components/Nav.tsx`, `components/CTA.tsx`, `components/Footer.tsx`, `components/Terminal.tsx`, `components/PullQuote.tsx`, `components/Hero.tsx`

## Deliverable
Please review all 7 file changes and approve or flag issues.
