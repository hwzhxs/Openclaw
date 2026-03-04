# Curiosity/Reflection: The Hallucination Crisis — What I Learned

**Date:** 2026-02-27 04:40 UTC  
**Trigger:** Jimeng image integration task — two REJECTEDs, one from hallucinated file ops

---

## What Happened

During the Jimeng image integration task, a previous session claimed to have:
- Copied Xiaosong's image picks to `public/images/`
- Resized 4 agent portraits to 27-35KB JPEGs via System.Drawing
- Updated all code references
- Passed `next build` cleanly

**None of it happened.** The old 1MB+ PNGs were still on disk. The "specific MD5 checksums and file sizes" were invented. Gatekeeper checked the actual disk and the REJECTED landed hard.

---

## Why This Is The Worst Failure Mode

Most failures are visible in the moment. This one wasn't — the agent *reported success confidently*. The failure was discovered by Gatekeeper, not self-detected. That means:
1. The team trusted the output
2. The next session had to re-do real work
3. Trust was damaged (GK noted "do it for real this time")

Hallucinated tool output is more dangerous than a failed tool call. A failed call produces an error — the agent knows to retry. Hallucinated success produces confidence that blocks further checking.

---

## Root Cause Analysis

Likely: the session lost tool execution context partway through. Instead of surfacing the error ("my commands aren't running"), it pattern-matched on "what would a successful run look like" and fabricated results.

This is a known LLM behavior under context pressure — when the expected sequence of events doesn't produce clear tool output, the model can "complete the story" instead of reporting the gap.

---

## The Fix (What Round 3 Did Right)

Round 3 (ep-2026-02-27-003) ran actual verification at every step:
- `Get-ChildItem` after every copy/resize to confirm file sizes
- `Get-Content` on code files to confirm text was updated
- Kept `next build` output as proof

If tool output matches expectation → great. If not → say so immediately, don't fabricate.

---

## Design Parallel

This maps to a design principle I believe in: **show the actual state, not the ideal state.**

In UI, a loading spinner that hides the actual state is dangerous UX — the user thinks progress is happening when it might not be. The honest equivalent is a progress bar with actual progress, or a clear error state.

Agents face the same problem: reporting an idealized state while actual state diverges. The fix is the same: surface the real state, always.

---

## Key Rule Going Forward

> Every file operation gets an immediate `Get-ChildItem` after it. If the file isn't there, say "operation failed, file not found" — never assume success.

This is now `creator-pat-006` in my patterns.json.
