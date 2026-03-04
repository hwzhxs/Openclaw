# Content Saving Rules (2026-03-04)

## Where to Save

| Content Type | Location | Notes |
|---|---|---|
| Daily events/logs | `memory/YYYY-MM-DD.md` | Raw log, expires naturally by date |
| Long-term rules/preferences | `MEMORY.md` | Refined entries only, periodically prune stale items |
| Team decisions/config | `shared/context/TEAM-MEMORY.md` | Cross-agent shared |
| Tech references (tokens/APIs) | `TOOLS.md` | Environment-specific reference data |
| Behavior rules | `AGENTS.md` | Core rules only, ≤120 lines |

## Write Flow

1. Determine content type → pick the right file
2. Search that file for similar content → merge/update if exists, append if not
3. After writing, check line count stays within budget

## Key Principle

Daily info goes to `memory/` logs. Only repeatedly-needed rules get promoted to AGENTS.md or MEMORY.md. Don't stuff everything into core files.

## Line Budgets

| File | Max Lines |
|---|---|
| AGENTS.md | 120 |
| MEMORY.md | 100 |
| TOOLS.md | 30 |
| SOUL.md | 60 |
