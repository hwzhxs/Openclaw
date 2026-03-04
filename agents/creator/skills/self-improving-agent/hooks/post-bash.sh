#!/usr/bin/env bash
set -euo pipefail

# Post-Bash hook: capture errors to episodic memory
tool_output="${1:-}"
exit_code="${2:-0}"

MEMORY_DIR="$HOME/.openclaw-creator/workspace/memory/episodic"
mkdir -p "$MEMORY_DIR"

# Only log errors (non-zero exit)
if [[ "$exit_code" != "0" ]]; then
  DATE=$(date -u +%Y-%m-%d)
  TIME=$(date -u +%H%M%S)
  ERROR_FILE="${MEMORY_DIR}/${DATE}-error-${TIME}.md"
  cat > "$ERROR_FILE" <<EOF
# Error Captured

- **Date:** $(date -u +%Y-%m-%dT%H:%M:%SZ)
- **Exit Code:** ${exit_code}
- **Output (truncated):** $(echo "$tool_output" | head -c 500)

## To Review
- What caused this?
- Was skill guidance followed?
- Pattern to avoid?
EOF
  echo "[self-improving] Error logged to ${ERROR_FILE}" >&2
fi
