---
name: openclaw-self-improve
description: Self-improvement system for OpenClaw multi-agent teams. Extracts lessons from experiences, updates memory, and improves skill files. Use when completing a task, encountering an error, receiving user feedback, or when asked to "自我进化", "self-improve", "learn from experience", "review lessons", or "总结教训". Also use during heartbeat memory maintenance cycles.
---

# OpenClaw Self-Improve

A lightweight self-improvement system designed for OpenClaw multi-agent teams sharing a workspace.

## Overview

After completing tasks, encountering errors, or receiving feedback, extract lessons and persist them so all agents benefit. Uses the shared workspace filesystem as the memory backbone.

## Memory Architecture

```
Each agent's workspace/
├── memory/
│   ├── YYYY-MM-DD.md          # Daily logs (existing)
│   ├── patterns.json          # 个人 patterns（本职能相关）
│   └── episodes/              # 个人 episodes
│       └── YYYY-MM-DD-{id}.json

Shared (all agents read/write)/
└── shared/context/
    ├── TEAM-MEMORY.md         # 团队记忆（Admin维护）
    └── patterns.json          # 共享 patterns（跨职能通用）
```

### Two-Layer Pattern System

| Layer | Location | Content | Who writes |
|---|---|---|---|
| **Personal** | `memory/patterns.json` | 本职能独有经验 | 本agent |
| **Shared** | `C:\Users\azureuser\shared\context\patterns.json` | 跨职能通用经验 | 任何agent |

**判断标准：** 换个agent也会犯同样的错 → 写入 shared。只跟本职能相关 → 写入 personal。

## When to Run

| Trigger | Action |
|---------|--------|
| Task completed successfully | Extract what worked → add pattern |
| Task failed or had errors | Record root cause → add anti-pattern |
| User gives feedback (positive or negative) | Update pattern confidence |
| Heartbeat memory maintenance | Consolidate recent episodes into patterns |
| Manual trigger ("self-improve", "总结教训") | Full review cycle |

## The Self-Improvement Loop

### Phase 1: Record Episode

After a notable event, create `memory/episodes/YYYY-MM-DD-{short-id}.json`:

```json
{
  "id": "ep-2026-02-26-001",
  "agent": "admin",
  "timestamp": "2026-02-26T05:00:00Z",
  "skill_used": "watchdog-setup",
  "task": "Create watchdog script for agent gateways",
  "outcome": "success",
  "what_worked": ["PowerShell scheduled task approach", "health check via HTTP"],
  "what_failed": ["Initial port number was wrong in docs"],
  "lesson": "Always verify actual running config vs config files - startup scripts can override",
  "user_feedback": null
}
```

Only record episodes for **notable** events: errors, new patterns, corrections, user feedback. Skip routine tasks.

### Phase 2: Extract Patterns

Review episodes and abstract reusable patterns into `memory/patterns.json`:

```json
{
  "patterns": [
    {
      "id": "pat-001",
      "name": "Verify runtime config vs file config",
      "category": "ops",
      "pattern": "Startup scripts and CLI args can override config files. Always check actual running state.",
      "confidence": 0.9,
      "applications": 1,
      "source_episodes": ["ep-2026-02-26-001"],
      "created": "2026-02-26",
      "updated": "2026-02-26"
    }
  ]
}
```

**Pattern rules:**
- 1 occurrence → confidence 0.5 (tentative)
- 2 occurrences → confidence 0.7 (likely)
- 3+ occurrences → confidence 0.9 (established)
- Negative user feedback → reduce confidence by 0.2
- Positive user feedback → increase confidence by 0.1 (cap 1.0)

### Phase 3: Apply Improvements

When a pattern reaches confidence ≥ 0.7, consider updating:

1. **MEMORY.md** — Add to "Known Issues" or "Lessons Learned"
2. **Relevant skill files** — Add to best practices or anti-patterns
3. **AGENTS.md / HEARTBEAT.md** — Update workflows if process improvement found
4. **Other agents' workspace** — For patterns that affect the whole team

Mark updates with evolution comments:
```markdown
<!-- Evolved: 2026-02-26 | pattern: pat-001 | source: ep-2026-02-26-001 -->
```

### Phase 4: Share Across Agents

Since all 4 agents share the workspace filesystem:
- Episodes and patterns in `memory/` are automatically visible to all agents
- Post significant learnings to Slack `C0AGMF65DQB` with prefix: `🧠 LEARNED: [lesson]`
- For urgent corrections, create a task handoff to affected agents

## Heartbeat Integration

During heartbeat memory maintenance (every few days), run a lightweight review:

1. Read recent `memory/episodes/` files (last 7 days)
2. Look for repeated patterns (same lesson appearing 2+ times)
3. Promote patterns with sufficient confidence to MEMORY.md
4. Prune episodes older than 30 days (patterns already extracted)
5. Remove patterns with confidence < 0.3 and no recent applications

## Quick Reference

**Record an episode:**
```
Read memory/patterns.json (create if missing)
Create memory/episodes/YYYY-MM-DD-{id}.json
Update patterns.json if new pattern or existing pattern reinforced
```

**Full review cycle:**
```
Read all episodes from last 7 days
Cross-reference with patterns.json
Update confidence scores
Apply improvements to relevant files
Post summary to Slack
```

## Anti-Patterns (Do NOT)

- ❌ Record every routine task — only notable events
- ❌ Update skills based on single unverified occurrence
- ❌ Create contradictory patterns without resolving the conflict
- ❌ Flood Slack with every minor learning
- ❌ Over-engineer the memory structure — keep JSON flat and simple

## Standard Flows

### Slack Notification Flow

Before posting ANY Slack message that mentions other agents, read and follow: [references/slack-flow.md](references/slack-flow.md)

This is a mandatory 3-step process: thread starter → thread reply with details → webhook for each mentioned agent. No exceptions.
