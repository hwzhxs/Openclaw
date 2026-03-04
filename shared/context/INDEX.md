# Team Knowledge Library (INDEX)

This is the single entry point for team knowledge.

## Where to put things (routing rules)

### 1) Daily log (time-based, raw)
- **Path:** `memory/YYYY-MM-DD.md`
- **Use for:** what happened today, decisions made, links, quick notes.
- **Rule:** if it’s only in Slack and not written here, it will be lost next session.

### 2) Knowledge (topic-based, reusable)
- **Path:** `shared/context/knowledge/`
- **Use for:** anything we want to reuse across projects/sessions (process, runbooks, configs, product notes, prompt templates).

### 3) Team consensus (small + critical)
- **Path:** `shared/context/TEAM-MEMORY.md`
- **Use for:** the few cross-team rules/agreements that must stay consistent.

### 4) Runtime state (machine-written)
- **Path:** `shared/context/runtime/`
- **Use for:** JSON/SQLite/logs produced and consumed by scripts.

### 5) Private/personal preferences (do not post in group)
- **Path:** `USER.md` / private memory layer
- **Use for:** personal preferences, sensitive info.

## Navigation

### Process & Norms
- `shared/context/slack-rules.md`
- `shared/context/task-checklist.md`
- `shared/context/knowledge/process/`

### Runbooks (ops / incidents / debugging)
- `shared/context/knowledge/runbooks/`
- `shared/context/knowledge/runbooks/monitoring-pulse.md`  *(canonical monitoring memory + runbook)*

### Product / Competitors / Market
- `shared/context/knowledge/product/`

### Technical (architecture / config / how-to)
- `shared/context/knowledge/tech/`

### Prompts / Templates
- `shared/context/knowledge/prompts/`
- `shared/context/task-template.md`

### Projects (one project = one directory)
- `shared/context/knowledge/projects/`
- `shared/context/knowledge/projects/xiaohongshu/` *(Xiaohongshu project hub)*

## Weekly archive + dedupe (cadence)

**Goal:** prevent “lots of logs, no library”.

Every week (or when messy), do:
1. Scan `memory/YYYY-MM-DD.md` for the week.
2. Promote reusable items into `shared/context/knowledge/**`.
3. Dedupe/merge entries (keep **source link/date** in the file).
4. If it’s a rule/agreement → update `TEAM-MEMORY.md`.

## Anti-pattern (explicitly banned)

- **Banned:** “Conclusion only in Slack thread, not written to files.”
- **Replacement rule:** Slack can be the *discussion*, but the *final answer* must be written into the right layer within **24h**.
