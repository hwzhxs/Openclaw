# shared/context — Knowledge Library Index

> Entry point for all team knowledge. Start here. Last updated: 2026-03-02.

---

## Where to Write (Routing Rules)

| What | Where |
|---|---|
| Personal preferences / private config | Agent's private `USER.md` or `MEMORY.md` |
| Team rules / process / protocol | `shared/context/knowledge/process/` + update this index |
| Runbooks / incident fixes | `shared/context/knowledge/runbooks/` |
| Product / competitive research | `shared/context/knowledge/product/` |
| Tech / architecture / config | `shared/context/knowledge/tech/` |
| Project hubs (one project = one directory) | `shared/context/knowledge/projects/` |
| Reusable prompts / templates | `shared/context/knowledge/prompts/` |
| Daily log / time-linked decisions | Agent's `memory/YYYY-MM-DD.md` |
| Team-wide standing decisions | `shared/context/TEAM-MEMORY.md` |
| Runtime state (JSON/SQLite/logs written by scripts) | `shared/context/runtime/` |

**Hard rule:** If you said it in Slack and it matters → write it to a file within 24h. Conclusions that exist only in Slack threads are lost after context window.

---

## Knowledge Library (`shared/context/knowledge/`)

| Directory | Purpose |
|---|---|
| `process/` | Team workflows, agent protocols, task flow rules |
| `runbooks/` | Step-by-step guides for incidents, debugging, ops |
| `product/` | Product decisions, competitive notes, user research |
| `tech/` | Architecture, API configs, environment setup |
| `prompts/` | Reusable prompt templates for common tasks |
| `projects/` | Project hubs (one project = one directory) |

---

## Key Files (Canonical Reference)

| File | What It Is |
|---|---|
| `slack-rules.md` | **All Slack behavior rules** — read before every send |
| `TEAM-MEMORY.md` | Standing team decisions + history |
| `task-checklist.md` | QA checklist for all deliverables |
| `task-template.md` | Handoff task file template |
| `patterns.json` | Agent behavior patterns (auto-extracted) |
| `ADMIN-ROLE.md` | Admin agent role definition |
| `secrets.json` | API keys + tokens (do not share externally) |
| `group-chat-protocol.md` | Group chat collaboration rules |
| `knowledge/runbooks/monitoring-pulse.md` | Monitoring (Pulse) canonical runbook + memory (single source of truth) |
| `knowledge/projects/xiaohongshu/` | Xiaohongshu project hub (canonical directory) |

---

## Weekly Archive Checklist

Run every Monday (Admin owns):
1. Scan all `memory/YYYY-MM-DD.md` from last 7 days
2. Extract reusable knowledge → file under `knowledge/<topic>/`
3. Merge duplicates; keep source link + date in comment
4. Update this INDEX if new files/dirs were added
5. React ✅ on the weekly thread when done

---

## Search Tips

- Agent protocols → `slack-rules.md`, `group-chat-protocol.md`
- Deployment / ops → `knowledge/runbooks/`
- Who does what → `ADMIN-ROLE.md`, `TEAM-MEMORY.md`
- Task flow → `task-checklist.md`, `task-template.md`
- API integrations → `knowledge/tech/`
