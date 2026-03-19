#!/bin/bash
# Hook: block-destructive-commands (PreToolUse on Bash)
# Blocks dangerous commands that could destroy work or compromise security.
# Exit 2 = block + stderr shown to Claude as feedback.

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name // empty' 2>/dev/null || echo "")

[ "$tool_name" != "Bash" ] && exit 0

command=$(echo "$input" | jq -r '.tool_input.command // empty' 2>/dev/null || echo "")
[ -z "$command" ] && exit 0

# Block rm -rf / rm -fr (suggest trash instead)
if echo "$command" | grep -qE 'rm\s+-(rf|fr)\s'; then
  echo "BLOCKED: rm -rf is destructive and irreversible." >&2
  echo "Use 'trash' (brew install trash) or move to a temp directory instead." >&2
  echo "If you truly need to delete, ask the user for explicit confirmation first." >&2
  exit 2
fi

# Block git push to main/master without explicit branch
if echo "$command" | grep -qE 'git\s+push.*--force'; then
  echo "BLOCKED: Force push is destructive and can overwrite remote history." >&2
  echo "Use 'git push' without --force, or ask the user for explicit confirmation." >&2
  exit 2
fi

# Block direct push to main/master
if echo "$command" | grep -qE 'git\s+push\s+(origin\s+)?(main|master)\b'; then
  current_branch=$(git branch --show-current 2>/dev/null || echo "")
  if [ "$current_branch" = "main" ] || [ "$current_branch" = "master" ]; then
    echo "BLOCKED: Pushing directly to $current_branch." >&2
    echo "Create a feature branch first, or ask the user for explicit confirmation." >&2
    exit 2
  fi
fi

# Block sudo
if echo "$command" | grep -qE '^\s*sudo\s'; then
  echo "BLOCKED: sudo commands require explicit user confirmation." >&2
  echo "Describe what you need to do and ask the user to run it manually." >&2
  exit 2
fi

# Block pipe-to-shell attacks
if echo "$command" | grep -qE '(curl|wget)\s.*\|\s*(bash|sh|zsh)'; then
  echo "BLOCKED: Piping downloads directly to shell is a security risk." >&2
  echo "Download the script first, review it, then execute." >&2
  exit 2
fi

# Block disk-level destructive commands
if echo "$command" | grep -qE '^\s*(mkfs|dd|fdisk|diskutil\s+eraseDisk)\s'; then
  echo "BLOCKED: Disk-level operations are extremely destructive." >&2
  echo "Ask the user to run this manually after review." >&2
  exit 2
fi

exit 0
