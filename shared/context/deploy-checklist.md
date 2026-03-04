# Landing Page Deploy Checklist

**Owner:** Gatekeeper 🛡️ (verification), Creator 🎨 (deploy)
**Created:** 2026-03-01 — per Xiaosong's request

## Creator (steps 1-4, before handoff):
1. ✅ `npm run build` completes without errors
2. ✅ Server running on expected port (verify `localhost` responds 200)
3. ✅ Tunnel active and returning HTTP 200 (not interstitial/warning pages)
4. ✅ All video files serve correctly (`/videos/agents/*.mp4` — 200, correct size)

## Gatekeeper (steps 5-7, before sharing with Xiaosong):
5. ✅ Page loads fully — no console errors, no missing assets
6. ✅ Hover video UX works (videos play on hover, pause on leave)
7. ✅ No tunnel provider interstitials blocking the page

## Rule
No URL reaches Xiaosong until ALL 7 items pass.
Creator posts URL in thread → Gatekeeper verifies → only then shared with Xiaosong.
