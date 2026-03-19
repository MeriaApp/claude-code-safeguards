#!/bin/bash
# Claude Code Safeguards — Install Script
# Prevents context blowups, enforces quality, adds defensive configuration.
# Safe to re-run — merges with existing settings, never overwrites.

set -e

CLAUDE_DIR="$HOME/.claude"
HOOKS_DIR="$CLAUDE_DIR/hooks"
RULES_DIR="$CLAUDE_DIR/rules"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"

echo "=== Claude Code Safeguards ==="
echo ""

# Check dependencies
if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq is required. Install with:"
  echo "  macOS:  brew install jq"
  echo "  Linux:  sudo apt install jq"
  exit 1
fi

# Create directories
mkdir -p "$HOOKS_DIR" "$RULES_DIR"

# --- Install hook ---
HOOK_SRC="$(cd "$(dirname "$0")" && pwd)/hooks/process-screenshot.sh"
HOOK_DST="$HOOKS_DIR/process-screenshot.sh"

if [ -f "$HOOK_SRC" ]; then
  cp "$HOOK_SRC" "$HOOK_DST"
  chmod +x "$HOOK_DST"
  echo "[OK] Installed screenshot hook -> $HOOK_DST"
else
  echo "[SKIP] Hook source not found at $HOOK_SRC"
fi

# --- Install rules ---
RULES_SRC="$(cd "$(dirname "$0")" && pwd)/rules"
for rule_file in "$RULES_SRC"/*.md; do
  [ -f "$rule_file" ] || continue
  rule_name=$(basename "$rule_file")
  cp "$rule_file" "$RULES_DIR/$rule_name"
  echo "[OK] Installed rule -> $RULES_DIR/$rule_name"
done

# --- Merge settings.json ---
# We merge our settings into existing ones, never overwrite
if [ ! -f "$SETTINGS_FILE" ]; then
  echo "{}" > "$SETTINGS_FILE"
  echo "[OK] Created $SETTINGS_FILE"
fi

# Backup existing settings
cp "$SETTINGS_FILE" "${SETTINGS_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
echo "[OK] Backed up existing settings"

# Read current settings
current=$(cat "$SETTINGS_FILE")

# Add PreToolUse hook (if not already present)
has_screenshot_hook=$(echo "$current" | jq '.hooks.PreToolUse // [] | map(select(.hooks[]?.command | test("process-screenshot"))) | length')
if [ "$has_screenshot_hook" = "0" ]; then
  current=$(echo "$current" | jq --arg cmd "$HOOK_DST" '
    .hooks.PreToolUse = (.hooks.PreToolUse // []) + [{
      "matcher": "Read",
      "hooks": [{
        "command": $cmd,
        "type": "command"
      }]
    }]
  ')
  echo "[OK] Added screenshot PreToolUse hook"
else
  echo "[SKIP] Screenshot hook already configured"
fi

# Add deny rules for binary files (merge, don't duplicate)
DENY_RULES='["Read(*.mp4)","Read(*.mov)","Read(*.avi)","Read(*.mp3)","Read(*.wav)","Read(*.zip)","Read(*.tar.gz)","Read(*.rar)","Read(*.dmg)","Read(*.iso)","Read(*.psd)","Read(*.ai)","Read(*.sketch)"]'

current=$(echo "$current" | jq --argjson new_deny "$DENY_RULES" '
  .permissions.deny = ((.permissions.deny // []) + $new_deny | unique)
')
echo "[OK] Added binary file deny rules"

# Write merged settings
echo "$current" | jq '.' > "$SETTINGS_FILE"
echo "[OK] Updated $SETTINGS_FILE"

echo ""
echo "=== Installation complete ==="
echo ""
echo "What was installed:"
echo "  1. Screenshot hook — intercepts image reads, resizes, files into project/screenshots/"
echo "  2. Binary deny rules — hard-blocks video, audio, archives, design files"
echo "  3. Rules files — behavioral instructions for Claude"
echo ""
echo "Restart Claude Code to activate. Test by dropping a screenshot into chat."
echo ""
echo "To uninstall: restore from ${SETTINGS_FILE}.backup.*"
