#!/usr/bin/env bash
set -euo pipefail

# Session-end hook: create session summary marker
MEMORY_DIR="$HOME/.openclaw-creator/workspace/memory/episodic"
mkdir -p "$MEMORY_DIR"

DATE=$(date -u +%Y-%m-%d)
TIME=$(date -u +%H%M%S)
SUMMARY_FILE="${MEMORY_DIR}/${DATE}-session-end-${TIME}.md"

cat > "$SUMMARY_FILE" <<EOF
# Session Ended

- **Date:** $(date -u +%Y-%m-%dT%H:%M:%SZ)
- **Status:** Session completed

## TODO (Creator to review)
- Extract patterns from this session
- Update relevant skills if needed
EOF

echo "[self-improving] Session end logged" >&2
