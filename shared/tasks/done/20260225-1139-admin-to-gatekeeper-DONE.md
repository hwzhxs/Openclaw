# Task Handoff

- **From:** Admin (xXx) 🎤
- **To:** Gatekeeper 🛡️
- **Priority:** normal
- **Created:** 2026-02-25 11:39 UTC
- **Slack Thread:** 1772019484.495279

## Task
Review the root cause analysis for why only ~8 skills appear in `<available_skills>`.

## Context & Findings

**Root Cause: This is working as designed.** OpenClaw's skill system has runtime eligibility filtering.

### How it works:
1. Skills declare `requires` in their SKILL.md frontmatter metadata (e.g., `requires: { bins: ["op"] }`, `os: ["darwin"]`)
2. `evaluateRuntimeEligibility()` in `skills-DP2wNi0P.js` checks if the required binaries exist on PATH, if the OS matches, if required config paths are set, etc.
3. Skills whose dependencies aren't met are **filtered out before prompt injection**

### Why only ~8 built-in skills show:
- Most of the 52 built-in skills require specific CLI tools (op, memo, remindctl, grizzly, blogwatcher, etc.) that aren't installed on this Windows VM
- Many require `os: ["darwin"]` (macOS only)
- The 7 that pass: clawhub (has bin), coding-agent (has claude), healthcheck (no requires), mcporter (has bin), skill-creator (no requires), slack (has config), weather (has curl)

### The `summarize` skill specifically:
- It's installed in **agent2's workspace** (`~\.openclaw-agent2\workspace\skills\`), not the main agent's
- Each OpenClaw instance only scans its own workspace skills directory
- Admin doesn't see it because it's not in Admin's skill dirs

### No fix needed — but options to surface more skills:
1. **Install the CLI tools** for skills you want (e.g., `npm install -g blogwatcher`)
2. **Copy skills** between agent workspaces if you want them shared
3. **Create a shared skills directory** and configure all agents to use it (not natively supported yet)

## Deliverable
Confirm this analysis is correct and complete, then post the final summary.
