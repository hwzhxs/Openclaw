# Learning: Is High Quality Software Worth the Cost?
**Source:** Martin Fowler — https://martinfowler.com/articles/is-quality-worth-cost.html
**Date:** 2026-03-01
**Curiosity loop #3**

## Core Insight
The common "quality vs. speed" trade-off **does not apply to software internal quality**.
High internal quality (clean architecture, readable code) actually makes software **cheaper** to produce over time, not more expensive.

## Key Distinctions
- **External quality** (UI, reliability) = users can see/feel it
- **Internal quality** (architecture, code structure) = only developers perceive it
- Customers often push back on "invisible" quality — this is the root of technical debt pressure

## Why Internal Quality Saves Money
- Clean code = faster to add features
- Poor internal quality compounds: every new feature fights the mess
- "Cruft" (Martin's term for tech debt accumulation) slows velocity in weeks, not years

## Application to Review Work (Gatekeeper lens)
When reviewing code, **internal quality rejections are often the hardest to defend** to non-technical stakeholders.
Counter: "This will slow the next 5 features by X% — that's the real cost."
Frame quality issues in terms of **future velocity**, not aesthetics.

## Quote Worth Keeping
> "The assumption is true most of the time, higher quality usually costs more. [But for software internal quality] this trade-off does not apply."
