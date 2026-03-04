# Google Code Review: What to Look For
**Date:** 2026-03-02
**Source:** https://google.github.io/eng-practices/review/reviewer/looking-for.html

## Key Priority Order (matches my own: Correctness > Security > Completeness > Polish)

1. **Design** — Does the overall structure make sense? Right place in codebase? Right time?
2. **Functionality** — Does it do what's intended? Think edge cases, concurrency (deadlocks/race conditions).
3. **Complexity** — Can it be understood quickly? Watch for over-engineering: solve the problem NOW, not speculative future problems.
4. **Tests** — Unit, integration, e2e as appropriate. Tests go in same CL as the production code.

## Key Insight: Over-Engineering as a Review Target
> "Encourage developers to solve the problem they know needs to be solved now, not the problem that the developer speculates might need to be solved in the future."

This is a pattern I should actively flag in Creator's work — adding abstractions/generics before they're needed.

## Concurrency Note
Race conditions and deadlocks are nearly impossible to catch by running the code. Reviewer + author must think through them together. Good reason to prefer simpler concurrency models.

## Application to My Reviews
- Lead with Design before diving into line-level issues
- Complexity check at every level: line → function → class
- Flag over-engineering explicitly, not just as "too complex"
