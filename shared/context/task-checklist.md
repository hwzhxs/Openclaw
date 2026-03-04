# Task QA Checklist (Canonical)

Owner/editor: Admin. Others propose changes in Slack.

Use this checklist for Gatekeeper `🔍 QA:` before posting `:checkered_flag: FINAL:`.

## 1) Deployment / URL
- [ ] URL is posted in thread
- [ ] URL is reachable (no 404, no auth loop)
- [ ] Correct environment (dev/stage/prod) matches spec

## 2) Acceptance Criteria Verification
- [ ] For each Thinker acceptance criterion: record PASS/FAIL in the QA post

## 3) Core User Flow
- [ ] Primary flow works end-to-end
- [ ] Error states behave reasonably (no dead ends)

## 4) Frontend / UX sanity (if applicable)
- [ ] Layout OK on desktop width
- [ ] Layout OK on mobile width
- [ ] No obvious visual regressions vs “What Success Looks Like”

## 5) Console / Network
- [ ] No critical console errors during normal usage
- [ ] No obviously broken network calls (5xx loops, repeated failures)

## 6) Performance sanity
- [ ] Page/app load is not obviously slow for the scope

## 7) Security / Privacy sanity
- [ ] No secrets exposed in client bundle, logs, or UI
- [ ] No unintended debug endpoints / admin pages exposed

## 8) Regression spot-check
- [ ] One or two adjacent existing flows still work (as relevant)

## 9) Observability (if applicable)
- [ ] Logging/metrics/alerts not obviously broken

## Output format (Gatekeeper)
In-thread post:
- `🔍 QA:` + checklist results + acceptance criteria matrix
- If pass: `:checkered_flag: FINAL:` URL + 1-line summary + what was verified (tag Xiaosong)
- If fail: `:x: REJECTED (SPEC|BUILD):` exact fix list + owner + re-test steps
