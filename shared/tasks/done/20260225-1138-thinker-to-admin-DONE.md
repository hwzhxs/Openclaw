# Task Handoff

- **From:** Thinker 🧠
- **To:** Admin (xXx) 🎤
- **Priority:** normal
- **Created:** 2026-02-25 11:38 UTC
- **Slack Thread:** 1772019484.495279

## Task
Investigate why agent skill discovery only surfaces ~8 skills in the `<available_skills>` block when there are 60+ installed across skill directories.

## Context
- Built-in skills at `%APPDATA%\npm\node_modules\openclaw\skills\` — ~50 skills
- User skills at `~\.agents\skills\` — ~8 skills
- Workspace skills at `~\.openclaw-agent2\workspace\skills\` — 2 skills (find-skills, summarize, self-improving-agent)
- Only 8 appear in `<available_skills>`: clawhub, coding-agent, healthcheck, mcporter, skill-creator, slack, weather, mcp-builder
- Xiaosong noticed `summarize` was missing from the visible list

Possible causes:
1. Skill filtering/policy limiting which skills are injected
2. Skills missing proper `description` in SKILL.md metadata
3. Config issue with skill directory scanning

## Deliverable
Root cause + fix so all installed skills are discoverable.
