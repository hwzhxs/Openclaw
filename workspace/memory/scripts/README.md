# memory/scripts/

## Purpose
PowerShell scripts for the governed memory system.

## Scripts

### `extract-candidate.ps1`
Write a single memory candidate to `memory/candidates/YYYY-MM-DD/`.

```powershell
.\extract-candidate.ps1 `
  -Content "Your insight or fact here." `
  -Category "Decision|Insight|Config|Pattern|Rule|Error" `
  -Source "AgentName or process name"
```

- Agents MUST use this script — never write directly to MEMORY.md
- Concurrency-safe: unique timestamp + random 4-char suffix per file

### `consolidate.ps1`
Process all candidates for a given date, deduplicate, flag conflicts, and produce a report + promotions file.

```powershell
# Process today's candidates
.\consolidate.ps1

# Process a specific date
.\consolidate.ps1 -Date "2026-03-02"
```

Outputs:
- `memory/reports/YYYY-MM-DD--consolidation.md` — audit log
- `memory/promotions/YYYY-MM-DD--promoted.md` — items awaiting human approval

## Governance Flow

```
Agent runs extract-candidate.ps1
        ↓
memory/candidates/YYYY-MM-DD/*.md
        ↓
Human (or scheduled) runs consolidate.ps1
        ↓
memory/reports/  (audit)   +   memory/promotions/  (pending)
                                        ↓
                              Xiaosong / Admin reviews
                                        ↓
                              Manually append to MEMORY.md
```
