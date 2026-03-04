# Memory Governance Policy
**Approved by:** Gatekeeper 🛡️
**Date:** 2026-03-02
**Status:** APPROVED
**Slack thread:** 1772417175.906189

---

## 1. What Agents May Write Directly (no review required)

- `memory/YYYY-MM-DD.md` — per-agent daily episodic log (append-only; never in-place edit)
- `memory/episodes/*.json` — individual episode records (new files only; never overwrite)
- `memory/candidates/YYYY-MM-DD/*.md` — extracted candidate memories (new files only)
- Own agent's `memory/patterns.json` — personal patterns file (append or update confidence scores)

**Rule: All direct writes are APPEND-ONLY or CREATE-NEW. No in-place replacement of existing content.**

---

## 2. What Requires Candidate + Review (never auto-write)

The following files must NEVER be written to directly by any agent during normal operation:

| File | Reason |
|---|---|
| `MEMORY.md` (any agent's core memory) | Curated core — poisoning risk is highest here |
| `shared/context/TEAM-MEMORY.md` | Cross-agent shared truth — Admin sole editor |
| `shared/context/patterns.json` | Shared patterns — any agent may append, but no silent overwrites of existing entries |
| `shared/context/entities.json` | High-value relationship graph — append or propose diff |

**Promotion path:** candidate → consolidation job review → explicit promotion with `learned_at` + `source` fields.

**Exception:** Admin may promote to `TEAM-MEMORY.md` after Gatekeeper review.

---

## 3. Conflict Handling Rules

1. **Never silently overwrite.** If new information contradicts an existing entry, write the new fact as a candidate with a `conflicts_with` field referencing the existing entry's ID or line.
2. **Conflict surfaced, not resolved.** The consolidation job flags conflicts as "needs review" — it does NOT pick a winner automatically.
3. **Recency wins only after explicit review.** A newer timestamp alone does not override an existing fact; a human or Gatekeeper review is required to promote.
4. **Agents encountering a conflict mid-task** must stop, write the candidate with `conflicts_with`, and surface it in the consolidation report. Do not proceed as if one version is correct.

---

## 4. TTL / Recency / Validation Requirements

Every entry promoted to Core (MEMORY.md, TEAM-MEMORY.md) MUST include:

```
learned_at: <UTC ISO timestamp>
source: <Slack thread ts or file path>
ttl_days: <optional integer; omit = no expiry>
last_validated_at: <UTC ISO timestamp, set by consolidation or manual review>
```

- Entries missing `learned_at` + `source` are **invalid** and must not be promoted.
- Entries with `ttl_days` set: consolidation job flags them as expired if `today > learned_at + ttl_days`. Expired entries are demoted to candidates, not deleted.
- Entries not validated within 90 days should be flagged in the consolidation report for revalidation.

---

## 5. Multi-Agent Contention

Locked architecture: **append-only + merge** (D1 decision, Xiaosong confirmed 2026-03-02).

- No agent holds a write lock on any shared file.
- Each agent writes to its own append-only structures.
- Merges happen exclusively in the consolidation job.
- If two agents produce conflicting candidates in the same run, both are preserved and flagged.

**Hard prohibition:** No agent may read a shared file, modify it in memory, and write the full modified version back. This is a silent overwrite and violates policy.

---

## 6. What Counts as "Notable" (auto-extraction trigger)

Auto-extraction into candidates is triggered by:
- A Slack thread with a locked decision (confirmed by Xiaosong or Admin ✅)
- A task completion (DEPLOYED → QA PASS → FINAL)
- An error or rejection that surfaces a new failure mode
- User feedback (positive or negative) that changes a behavior
- A config change, gateway fix, or infrastructure update

**Not notable:** routine task pickups, emoji reactions, duplicate-point posts, meta-discussion without a decision.

---

## 7. Consolidation Report Standard

Each consolidation run produces `memory/reports/YYYY-MM-DD--consolidation.md` containing:

```
## Summary
- Candidates reviewed: N
- Promoted to core: N
- Flagged (conflict): N
- Flagged (expired/TTL): N
- No action: N

## Promoted
- [entry] | learned_at | source

## Conflicts (needs review)
- [entry A] vs [entry B] | reason

## Expired / Needs Revalidation
- [entry] | learned_at | ttl_days
```

Missing or empty reports = consolidation job did not run or failed. Gatekeeper flags this.
