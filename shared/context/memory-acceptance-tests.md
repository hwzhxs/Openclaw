# Memory System — Acceptance Test Checklist
> For: Creator's implementation review | By: Gatekeeper 🛡️ | 2026-03-02

## D1: Write Safety (Multi-Agent Contention)

- [ ] **D1.1** Two agents writing to `memory/candidates/` simultaneously → both entries preserved, no data loss
- [ ] **D1.2** No agent can overwrite another agent's daily log (`memory/YYYY-MM-DD.md` is per-workspace)
- [ ] **D1.3** `shared/context/TEAM-MEMORY.md` writes are append-only (verify no read-modify-write pattern)
- [ ] **D1.4** `MEMORY.md` has no direct writes from auto-extraction or heartbeat (only via explicit promotion)

## D2: Memory Folder Schema

- [ ] **D2.1** `memory/candidates/` directory exists and is used for all new extracted memories
- [ ] **D2.2** Candidate files follow naming: `YYYY-MM-DD--<slug>.md`
- [ ] **D2.3** `memory/reports/` directory exists for consolidation output
- [ ] **D2.4** `shared/context/entities.json` has a valid schema (array of objects with `name`, `type`, `relationships`)

## D3: Memory Entry Format

- [ ] **D3.1** Every candidate entry includes `learned_at:` (UTC)
- [ ] **D3.2** Every candidate entry includes `source:` (thread ID or URL)
- [ ] **D3.3** Promoted Core entries have both `learned_at` + `source` (reject promotion if missing)
- [ ] **D3.4** Optional `ttl_days` and `last_validated_at` fields are supported and not stripped during processing

## D4: Auto-Extraction

- [ ] **D4.1** Extraction writes ONLY to `memory/candidates/` — never to `MEMORY.md` or `shared/context/`
- [ ] **D4.2** Extraction runs during heartbeat or post-session — does not block real-time responses
- [ ] **D4.3** Each extraction produces 3-5 candidate entries max per session (no dump of entire conversation)
- [ ] **D4.4** Candidates include enough context to be reviewable without reading the source thread

## D5: Consolidation Job

- [ ] **D5.1** Produces a report at `memory/reports/YYYY-MM-DD--consolidation.md`
- [ ] **D5.2** Report lists: items added, items flagged as conflicts, items archived/skipped
- [ ] **D5.3** Conflicting facts are flagged with `[CONFLICT]` and NOT auto-resolved (surfaced for review)
- [ ] **D5.4** Deduplication works: identical or near-identical entries across agents are merged
- [ ] **D5.5** Old daily logs (>7 days) are summarized, not deleted

## Safety / Poisoning Mitigation

- [ ] **S1** No path traversal in candidate filenames (no `../`, no absolute paths)
- [ ] **S2** Candidate content is treated as untrusted — no executable code in memory files
- [ ] **S3** Consolidation never promotes more than 10 entries per run without flagging for review
- [ ] **S4** Memory files use English only (no encoding corruption across agents)

## Pass Criteria

- **All D* tests pass** → ✅ APPROVED
- **Any S* test fails** → ❌ REJECTED (security)
- **1-2 D* tests fail (non-critical)** → ❌ REJECTED (BUILD) with specific fix instructions
