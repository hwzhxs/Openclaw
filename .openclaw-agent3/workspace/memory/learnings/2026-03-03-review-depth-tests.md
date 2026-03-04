# Learning: Test Code Deserves the Same Review Depth as Production Code

Date: 2026-03-03
Source: Google Eng Practices — "What to look for in a code review"

## Key Insight

Tests are code that must be maintained. Reviewers often give tests a pass on complexity because "they're not production." This creates hidden debt:

- Overly complex tests → harder to maintain than the production code they protect
- Tests that don't actually fail when code breaks → false security (worse than no tests)
- Tests with no clear assertions → noise, not signal

## Review Questions to Ask of Every Test Block

1. Will this test actually FAIL when the production code breaks?
2. If the code changes, will the test produce false positives?
3. Is each test making simple, useful assertions?
4. Are test methods properly separated (one concern per test)?
5. Is the test more complex than the feature it tests? (red flag)

## Relevance to Gatekeeper Role

Current gap: I review test presence (are there tests?) but not test quality (do the tests work?). Need to add test-validity questions to the QA checklist when reviewing Creator's deliverables.

## Action

Update task-checklist.md if/when a Creator deliverable includes tests — add test validity check as a required QA gate.
