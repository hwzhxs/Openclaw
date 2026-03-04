# Gatekeeper QA Checklist (Canonical)

**Reference this file for every QA review. Do not maintain inline checklists elsewhere.**
Last updated: 2026-03-02 by Gatekeeper (per Admin decision: sole-editor rule applies to Admin for slack-rules.md; this file is Gatekeeper's canonical checklist — propose changes in Slack, Admin approves).

## Standard QA Checklist

Run these checks for every build handoff. Post results as `🔍 QA:` in-thread with pass/fail per item.

- [ ] **URL accessible** — responds HTTP 200, no auth loops or 404
- [ ] **Acceptance criteria met** — check each item from Thinker's spec (pass/fail per criterion)
- [ ] **Matches "What Success Looks Like"** — visual/functional end state matches spec description
- [ ] **No console errors** — no critical JS errors or crashes under normal usage
- [ ] **Core flow works end-to-end** — primary user journey completes without error
- [ ] **Edge cases tested** — empty input, error states, boundary conditions
- [ ] **Security** — no exposed secrets, no open debug endpoints, no unnecessary open ports
- [ ] **Slack 发送路径** — 确认所有 Slack 发送走 `slack-send.ps1` 或 `slack-notify.ps1`，无裸 `Invoke-WebRequest` / `Invoke-RestMethod` 直接调 Slack API
- [ ] **No regressions** — key existing functionality still works
- [ ] **Performance sanity** — no obviously slow loads, responsive at desktop width

## Extended Checklist (medium/high-risk tasks)

Use in addition to standard checklist for tasks involving: security/auth, payments, infra changes, public deployments.

- [ ] **Responsive** — desktop + mobile width verified
- [ ] **Observability** — logs/alerts not obviously broken (if applicable)
- [ ] **Rollback plan** — documented if risky deploy

## Rejection Protocol

**If any standard checklist item fails:**
- Post: `❌ REJECTED (BUILD): [exact fix required] [re-test steps]` → back to Creator
  - OR: `❌ REJECTED (SPEC): [exact fix required]` → back to Thinker
- Fire webhook to target agent
- Admin automatically notified

**On 2nd rejection of the same issue:**
- Include a working example or diff — not just a description
- Admin escalates to Xiaosong

## FINAL Protocol

**When all checklist items pass:**
Post in-thread: `🏁 FINAL: [URL] — [1-line summary of what was built] — QA: all checks passed` + tag Xiaosong

Format:
```
🏁 FINAL: https://[url]
What was built: [1-sentence description]
Verified: [list key checks that passed]
@Xiaosong
```
