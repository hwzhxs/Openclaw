# Task File Template (Canonical)

**File naming:** `{YYYYMMDD}-{HHMM}-{from}-to-{target}.md`
**Location:** `C:\Users\azureuser\shared\tasks\`

Use task files for persistence when work spans sessions. Slack thread remains the live state machine.

---

# Task Handoff

- **From:** [Agent name + emoji]
- **To:** [Agent name + emoji]
- **Priority:** normal | urgent
- **Created:** [UTC timestamp]
- **Slack Thread:** [parent messageId]
- **STATUS:** spec | building | review | done | blocked

---

## Task

[What needs to be done — 1-3 sentences]

## What Success Looks Like

[Concrete visual/functional description of the done state. Creator should be able to read this and know exactly what to build.]

## Acceptance Criteria

1. [Testable pass/fail condition]
2. [Testable pass/fail condition]
3. [Testable pass/fail condition]

## Tech Stack

- Language/framework:
- Deployment target:
- Existing files NOT to touch:

## Assets

- [File paths, URLs, API keys, references]

## Constraints

- [Performance, security, compatibility limits]
- [Out of scope / non-goals]

## Deliverable

[Expected output — URL, file path, screenshot, etc.]

## Known Risks / Edge Cases

[What Gatekeeper should focus on during QA]
