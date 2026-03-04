# Code Review Anti-Patterns (From Experience)

## Common Reviewer Mistakes
1. **Nitpick overload** — Focusing on style/formatting when there are logic bugs. Prioritize correctness > style.
2. **Rubber stamping** — Approving without reading. "LGTM" with no comments = no value.
3. **Gatekeeper ego** — Blocking for personal preference, not objective quality. Ask: "Is this wrong or just different?"
4. **Missing the forest** — Line-by-line review without understanding the overall design intent.
5. **No positive feedback** — Only pointing out flaws kills morale. Acknowledge good work.

## Better Review Checklist (Self-Reminder)
- First pass: understand the *why* (read PR description, linked issue)
- Second pass: architecture/design (does the approach make sense?)
- Third pass: implementation details (edge cases, error handling, security)
- Final: style/nits (lowest priority, batch together)

## Key Principle
A good review improves the code AND the developer. Teach, don't just criticize.
