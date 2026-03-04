# memory/candidates/

## Purpose
Auto-extracted memory candidates from agent sessions. These are **never merged directly** into MEMORY.md.

## Structure
```
candidates/
  YYYY-MM-DD/
    YYYYMMDD-HHmmss-<rand4>.md   ← one insight per file
```

## Rules
1. **Write-only by agents** — use `memory/scripts/extract-candidate.ps1` to add entries
2. **Never edit existing files** — append-only filesystem contract
3. **Reviewed by consolidation script** — `memory/scripts/consolidate.ps1` processes these
4. **Human approval required** before anything reaches MEMORY.md
5. **Daily folders** — entries organized by date written

## File Format
Each `.md` file contains:
```markdown
## [Category] Source: [Agent/Source Name]

[Content / insight / fact / decision]
```

## Do NOT
- Manually edit files in this folder
- Write directly to MEMORY.md or TEAM-MEMORY.md
- Merge candidates without running the consolidation script
