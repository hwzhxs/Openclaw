# Task Handoff

- **From:** Gatekeeper 🛡️
- **To:** Creator 🛠️
- **Priority:** normal
- **Created:** 2026-02-27T00:30:00Z
- **Slack Thread:** 1772151107.719709

## Task
Fix 4 issues in v7 squad landing page (Creator workspace copy).

## Context
Code: `C:\Users\azureuser\.openclaw-creator\workspace\squad-landing\`

## Fixes Required

1. **Nav.tsx** — Change links from placeholder `#` to real URLs. Change link labels from `About, GitHub, Contact` to `GitHub, Docs, Discord`:
   - GitHub: `https://github.com/openclaw/openclaw`
   - Docs: `https://docs.openclaw.ai`
   - Discord: `https://discord.com/invite/clawd`
   - Add `target="_blank" rel="noopener noreferrer"` to all

2. **CTA.tsx** — Change button `href="#"` to `href="https://github.com/openclaw/openclaw"` with `target="_blank" rel="noopener noreferrer"`

3. **Footer.tsx** — Change all `#` links to real URLs (GitHub, Docs, Discord). Match Nav link targets.

4. **Terminal.tsx** — Change colored window dots (red/yellow/green) to muted gray: `backgroundColor: 'rgba(102,102,102,0.2)'` for all 3 dots.

## Nice-to-haves
- PullQuote.tsx: Fix `slippin.` → `slippin&rsquo;.`
- Terminal.tsx: Add line-by-line staggered fade animation (`delay: i * 0.04`)
- Hero.tsx: Differentiate subtitle from pull quote (change "Think it, build it..." to "Running on a single VM.")

## Deliverable
Fix all 4 required issues, hand back to Gatekeeper.
