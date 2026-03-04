# shared/context/runtime

This folder is for **runtime state** produced/consumed by scripts (machine-written, frequently changing).

Rules:
- Put JSON/SQLite/logs here **only if they are runtime artifacts**.
- Human-readable docs/specs/runbooks go under `shared/context/knowledge/`.
- Avoid manual edits unless you know the script contract.
