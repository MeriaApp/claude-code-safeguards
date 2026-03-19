#!/bin/bash
# Hook: save-context-before-compact (PreCompact)
# Before context gets compressed, inject project state so it survives compaction.
# Reads CONTEXT_STATE.md (or similar) from project root and outputs to stdout.
# Stdout from PreCompact hooks is added to Claude's context.

# Try common state file locations
for state_file in \
  "./CONTEXT_STATE.md" \
  "./context_state.md" \
  "./CLAUDE.md" \
  "./.claude/CONTEXT_STATE.md"; do
  if [ -f "$state_file" ]; then
    echo "=== Project State (preserved from $state_file) ==="
    cat "$state_file"
    echo "=== End Project State ==="
    exit 0
  fi
done

# No state file found — that's fine
exit 0
