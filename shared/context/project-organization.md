# Project Knowledge Base Organization (Team Standard)

**Owner:** Admin (xXx)
**Status:** Standard (apply to all projects)
**Last updated:** 2026-03-03 (UTC)

## Goal
Keep multi-agent collaboration clean and scalable:
- Everyone can quickly find the right file
- No duplicated “truth sources” drifting over time
- Changes are auditable (who changed what / when)

## The Standard (must follow)
**One project = one folder + one index entrypoint + layered files by responsibility.**

### Canonical structure
```
shared/context/<project>/
├── README.md             # Single entrypoint (index + TL;DR)
├── runbook.md            # How to run / ops / setup (install, start, troubleshooting, security)
├── research.md           # Data collection + methodology + raw artifacts links
├── content-strategy.md   # Strategy + templates/playbooks (if applicable)
└── ops/
    ├── monitors.md       # Monitoring/alerts/watchers (if any)
    └── channel.md        # Channel registry / IDs / routing rules (if any)
```

### README rules (single entrypoint)
README **must** contain:
1) **TL;DR** (3–5 lines): current status + what to read first
2) **File map**: links to the layered files
3) **Change log**: dated bullets

README **must not** contain:
- Full research dumps
- Large tables that belong in research.md

## Collaboration rules (avoid “one person modifies, others乱改”) 
1) **Single-writer rule (default):** one designated Owner merges edits.
   - Others propose changes via Slack thread (“I want to add X to research.md section Y”) or PR.
2) **No parallel edits** to the same file without explicit coordination.
3) **No new ad-hoc files** in shared/context root for a project.
   - If you need a new file, add it under the project folder and link it from README.
4) **Back-compat pointers:** if an old file exists and people used it before, keep it as a *pointer* to the new README (do not keep two competing sources).

## Naming conventions
- Use lowercase + hyphens: `content-strategy.md`, `project-organization.md`
- Prefer one “project name” consistently in paths.

## When to split files further
Split only when a file becomes hard to scan:
- `runbook.md` > ~200 lines → split to `runbook/` folder, keep a runbook index.

## Definition of done (for a reorg)
- Folder exists with README + layered files
- README links work
- Legacy files converted to pointer(s)
- Owner declared
- Change log updated
