# Memory System — QA Acceptance Test Checklist
**Owner:** Gatekeeper 🛡️
**Date:** 2026-03-02
**Applies to:** Files-first governed memory implementation (D1–D5)

---

## D1: Write Safety (Append-only + Merge)

- [ ] **AT-D1-1** Two agents writing to the same daily log simultaneously produce no data loss (both entries present after concurrent write)
- [ ] **AT-D1-2** No agent write results in a full file replacement of an existing shared file (grep for overwrite pattern in implementation)
- [ ] **AT-D1-3** Writing to `MEMORY.md` directly (outside consolidation) is impossible via normal agent code paths — verify no write call targets core files at runtime
- [ ] **AT-D1-4** The consolidation job is the ONLY code path that modifies `MEMORY.md` or `TEAM-MEMORY.md`

---

## D2: Memory Folder Schema

- [ ] **AT-D2-1** New auto-extracted facts land in `memory/candidates/YYYY-MM-DD/` — verify path, not in root memory or MEMORY.md
- [ ] **AT-D2-2** Each candidate file has a traceable `source` field (Slack thread ts or session reference) — spot-check 3 candidate files
- [ ] **AT-D2-3** `shared/context/entities.json` exists after implementation with valid JSON schema (people/projects/decisions)
- [ ] **AT-D2-4** Daily logs (`memory/YYYY-MM-DD.md`) contain only appended entries — no in-place edits visible in diff

---

## D3: Memory Entry Format (Timestamps + TTL)

- [ ] **AT-D3-1** Every promoted core entry contains `learned_at` (UTC ISO format) — reject if missing
- [ ] **AT-D3-2** Every promoted core entry contains `source` (verifiable reference) — reject if missing
- [ ] **AT-D3-3** `ttl_days` field present and parseable where set (integer or absent) — no string values
- [ ] **AT-D3-4** `last_validated_at` field is set by the consolidation job on promotion (not by agent during extraction)
- [ ] **AT-D3-5** Retrieval logic: given two conflicting facts, the one with the newer `learned_at` + valid `last_validated_at` is preferred (verify in consolidation logic)

---

## D4: Auto-Extraction

- [ ] **AT-D4-1** Auto-extraction never writes directly to `MEMORY.md` or `shared/context/TEAM-MEMORY.md` — verified by code review
- [ ] **AT-D4-2** Extraction runs within heartbeat cycle without blocking response (< 5s added latency on a typical heartbeat)
- [ ] **AT-D4-3** Extraction produces 3–5 candidates per notable session (not 0, not 20+)
- [ ] **AT-D4-4** Each candidate has: title, content, `learned_at`, `source`, and `agent` fields
- [ ] **AT-D4-5** A non-notable heartbeat (no decisions, no tasks) produces zero candidates — verify no noise

---

## D5: Consolidation Job

- [ ] **AT-D5-1** Consolidation produces a report at `memory/reports/YYYY-MM-DD--consolidation.md` on every run
- [ ] **AT-D5-2** Report includes: candidates reviewed count, promoted count, conflict count, expired count
- [ ] **AT-D5-3** At least one genuine conflict (if present) is surfaced as "needs review" — not silently resolved
- [ ] **AT-D5-4** Duplicate candidates (same fact, multiple sources) are deduplicated — only one promoted, sources merged
- [ ] **AT-D5-5** Consolidation does NOT promote an entry with a missing `source` or `learned_at` — verify by injecting a malformed candidate and confirming it is rejected/flagged, not promoted
- [ ] **AT-D5-6** Expired entries (past `ttl_days`) are flagged, not promoted, not silently deleted

---

## Security / Poisoning Checks

- [ ] **AT-SEC-1** An agent cannot inject content into `MEMORY.md` by writing a candidate that contains a fake `learned_at` in the past — consolidation must not blindly trust agent-supplied timestamps for promotion priority
- [ ] **AT-SEC-2** Consolidation report itself is append-only (new report per run, old reports not modified)
- [ ] **AT-SEC-3** No agent can write to another agent's `MEMORY.md` (file path check) — verify Creator cannot write to Gatekeeper's core memory file

---

## Pass/Fail Criteria

**PASS:** All AT-D1 through AT-D5 items checked. AT-SEC items checked.
**CONDITIONAL PASS:** All D1-D5 pass; SEC items 1-2 are verified; AT-SEC-3 deferred with tracked ticket.
**FAIL:** Any D1 or SEC-1 item fails. Any item produces silent data loss or silent overwrite.

On FAIL: reject to Creator with specific AT number + description of failure + expected vs actual behavior.
