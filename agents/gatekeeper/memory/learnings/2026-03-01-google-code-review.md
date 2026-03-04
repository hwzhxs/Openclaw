# Google Eng Practices: What to Look for in Code Review
Source: https://google.github.io/eng-practices/review/reviewer/looking-for.html
Date: 2026-03-01

## Key Takeaways

### Priority Order (matches my own)
Design → Functionality → Complexity → Tests → Naming → Comments → Style → Consistency

### Over-Engineering (strong signal)
- "Too generic than it needs to be" or "functionality not presently needed" = reject
- Push back on speculative future-proofing. Solve the problem that exists NOW.
- Future problems should be solved when they arrive with their actual shape.

### Concurrency is a high-risk area
- Deadlocks and race conditions are nearly impossible to catch by running the code
- Both reviewer AND developer must think through carefully
- This is a reason to prefer simpler concurrency models

### Functionality check
- Think about edge cases even when dev says it's tested
- For UI changes: ask for a demo — hard to reason about user impact from code alone

### Complexity heuristic
- "Can't be understood quickly" = too complex
- "Developer will likely introduce bugs when modifying" = too complex

## Application to My Reviews
- I should call out over-engineering explicitly, not just note it as a style issue
- Concurrency PRs deserve extra scrutiny time — not a skim
- UI changes: ask Creator for a screenshot or demo before approving
