#!/bin/bash
# Claude Code Safeguards — Install Script
# Prevents context blowups, enforces quality, adds defensive configuration.
# Safe to re-run — merges with existing settings, never overwrites.

set -e

CLAUDE_DIR="$HOME/.claude"
HOOKS_DIR="$CLAUDE_DIR/hooks"
RULES_DIR="$CLAUDE_DIR/rules"
COMMANDS_DIR="$CLAUDE_DIR/commands"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"

echo ""
echo "  ╔══════════════════════════════════════╗"
echo "  ║    Claude Code Safeguards v1.2       ║"
echo "  ╚══════════════════════════════════════╝"
echo ""

# Check dependencies
if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq is required. Install with:"
  echo "  macOS:  brew install jq"
  echo "  Linux:  sudo apt install jq"
  exit 1
fi

# Create directories
mkdir -p "$HOOKS_DIR" "$RULES_DIR" "$COMMANDS_DIR"

# --- Install hooks ---
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing hooks..."
for hook_file in "$SCRIPT_DIR/hooks/"*.sh; do
  [ -f "$hook_file" ] || continue
  hook_name=$(basename "$hook_file")
  cp "$hook_file" "$HOOKS_DIR/$hook_name"
  chmod +x "$HOOKS_DIR/$hook_name"
  echo "  [OK] $hook_name"
done

# --- Install rules ---
echo ""
echo "Installing rules..."
for rule_file in "$SCRIPT_DIR/rules/"*.md; do
  [ -f "$rule_file" ] || continue
  rule_name=$(basename "$rule_file")
  cp "$rule_file" "$RULES_DIR/$rule_name"
  echo "  [OK] $rule_name"
done

# --- Install commands ---
echo ""
echo "Installing commands..."
for cmd_file in "$SCRIPT_DIR/commands/"*.md; do
  [ -f "$cmd_file" ] || continue
  cmd_name=$(basename "$cmd_file")
  cp "$cmd_file" "$COMMANDS_DIR/$cmd_name"
  echo "  [OK] /$cmd_name (invoke with /${cmd_name%.md})"
done

# --- Merge settings.json ---
echo ""
echo "Configuring settings..."

if [ ! -f "$SETTINGS_FILE" ]; then
  echo "{}" > "$SETTINGS_FILE"
fi

cp "$SETTINGS_FILE" "${SETTINGS_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
echo "  [OK] Backed up existing settings"

current=$(cat "$SETTINGS_FILE")

# Add JSON schema for autocomplete in editors
current=$(echo "$current" | jq '."$schema" = "https://json.schemastore.org/claude-code-settings.json"')

# --- Register hooks in settings ---

# PreToolUse: screenshot hook
has_screenshot_hook=$(echo "$current" | jq '.hooks.PreToolUse // [] | map(select(.hooks[]?.command | test("process-screenshot"))) | length')
if [ "$has_screenshot_hook" = "0" ]; then
  current=$(echo "$current" | jq --arg cmd "$HOOKS_DIR/process-screenshot.sh" '
    .hooks.PreToolUse = (.hooks.PreToolUse // []) + [{
      "matcher": "Read",
      "hooks": [{"command": $cmd, "type": "command"}]
    }]
  ')
  echo "  [OK] Screenshot hook (PreToolUse/Read)"
fi

# PreToolUse: destructive command blocker
has_destructive_hook=$(echo "$current" | jq '.hooks.PreToolUse // [] | map(select(.hooks[]?.command | test("block-destructive"))) | length')
if [ "$has_destructive_hook" = "0" ]; then
  current=$(echo "$current" | jq --arg cmd "$HOOKS_DIR/block-destructive-commands.sh" '
    .hooks.PreToolUse = (.hooks.PreToolUse // []) + [{
      "matcher": "Bash",
      "hooks": [{"command": $cmd, "type": "command"}]
    }]
  ')
  echo "  [OK] Destructive command blocker (PreToolUse/Bash)"
fi

# PreCompact: context preservation
has_compact_hook=$(echo "$current" | jq '.hooks.PreCompact // [] | map(select(.hooks[]?.command | test("save-context-before-compact"))) | length')
if [ "$has_compact_hook" = "0" ]; then
  current=$(echo "$current" | jq --arg cmd "$HOOKS_DIR/save-context-before-compact.sh" '
    .hooks.PreCompact = (.hooks.PreCompact // []) + [{
      "matcher": "",
      "hooks": [{"command": $cmd, "type": "command"}]
    }]
  ')
  echo "  [OK] Context preservation hook (PreCompact)"
fi

# --- Permissions ---

# Allow rules (eliminates constant permission prompts)
ALLOW_RULES='["Bash(*)","Read","Write","Edit","Glob","Grep","Agent","WebFetch","WebSearch"]'
current=$(echo "$current" | jq --argjson new_allow "$ALLOW_RULES" '
  .permissions.allow = ((.permissions.allow // []) + $new_allow | unique)
')
echo "  [OK] Allow rules (Bash, Read, Write, Edit, Glob, Grep, Agent, WebFetch, WebSearch)"

# Deny rules — binary files + secrets + credentials
DENY_RULES='[
  "Read(*.mp4)","Read(*.mov)","Read(*.avi)","Read(*.mkv)",
  "Read(*.mp3)","Read(*.wav)","Read(*.flac)","Read(*.aac)",
  "Read(*.zip)","Read(*.tar.gz)","Read(*.rar)","Read(*.7z)",
  "Read(*.dmg)","Read(*.iso)",
  "Read(*.psd)","Read(*.ai)","Read(*.sketch)","Read(*.fig)",
  "Read(~/.ssh/**)","Read(~/.gnupg/**)",
  "Read(~/.aws/**)","Read(~/.azure/**)","Read(~/.kube/**)",
  "Read(~/.docker/config.json)","Read(~/.npmrc)","Read(~/.pypirc)",
  "Read(~/.git-credentials)","Read(~/.gem/credentials)",
  "Read(**/*.pem)","Read(**/*.key)","Read(**/*.gpg)","Read(**/*.cert)","Read(**/*.crt)"
]'
current=$(echo "$current" | jq --argjson new_deny "$DENY_RULES" '
  .permissions.deny = ((.permissions.deny // []) + $new_deny | unique)
')
echo "  [OK] Deny rules (binary files + secrets + credentials)"

# --- Settings ---
current=$(echo "$current" | jq '.effortLevel = "high"')
echo "  [OK] Effort level: high"

# Write merged settings
echo "$current" | jq '.' > "$SETTINGS_FILE"
echo "  [OK] Settings written"

# ═══════════════════════════════════════════════
# Gemini CLI Setup (optional but recommended)
# ═══════════════════════════════════════════════

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  RECOMMENDED: Set up Gemini CLI"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Gemini CLI gives Claude a second brain — a different AI"
echo "  model for code review, large file analysis, and second"
echo "  opinions. Gemini Flash is FREE (60 req/min)."
echo ""
echo "  Gemini beats Claude at:"
echo "    - Code review accuracy (83% vs 72%)"
echo "    - Context window (1M tokens vs 200K)"
echo "    - Bulk processing (Flash free tier)"
echo ""

SETUP_GEMINI=false
if command -v gemini >/dev/null 2>&1; then
  echo "  [OK] Gemini CLI is already installed"
  # Check if API key is set
  if [ -n "$GEMINI_API_KEY" ]; then
    echo "  [OK] GEMINI_API_KEY is set"
  else
    echo "  [!!] GEMINI_API_KEY not found in environment"
    SETUP_GEMINI=true
  fi
else
  echo "  Gemini CLI is not installed."
  echo ""
  read -p "  Install Gemini CLI now? (y/n) " -n 1 -r
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "  Installing..."
    npm install -g @google/gemini-cli 2>&1 | tail -1
    echo "  [OK] Gemini CLI installed"
    SETUP_GEMINI=true
  else
    echo "  [SKIP] You can install later: npm install -g @google/gemini-cli"
  fi
fi

if [ "$SETUP_GEMINI" = true ]; then
  echo ""
  echo "  To get your free API key:"
  echo "    1. Go to: https://aistudio.google.com/apikey"
  echo "    2. Click 'Create API Key'"
  echo "    3. Copy the key"
  echo ""

  # Try to open the page
  if command -v open >/dev/null 2>&1; then
    read -p "  Open the API key page in your browser? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      open "https://aistudio.google.com/apikey"
      echo "  [OK] Opened in browser"
    fi
  elif command -v xdg-open >/dev/null 2>&1; then
    read -p "  Open the API key page in your browser? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      xdg-open "https://aistudio.google.com/apikey"
      echo "  [OK] Opened in browser"
    fi
  fi

  echo ""
  read -p "  Paste your Gemini API key (or press Enter to skip): " gemini_key
  if [ -n "$gemini_key" ]; then
    # Detect shell config file
    if [ -f "$HOME/.zshrc" ]; then
      SHELL_RC="$HOME/.zshrc"
    elif [ -f "$HOME/.bashrc" ]; then
      SHELL_RC="$HOME/.bashrc"
    else
      SHELL_RC="$HOME/.bashrc"
    fi

    # Check if already set
    if grep -q "GEMINI_API_KEY" "$SHELL_RC" 2>/dev/null; then
      echo "  [SKIP] GEMINI_API_KEY already in $SHELL_RC — update manually if needed"
    else
      echo "export GEMINI_API_KEY=\"$gemini_key\"" >> "$SHELL_RC"
      echo "  [OK] Added GEMINI_API_KEY to $SHELL_RC"
      echo "  Run: source $SHELL_RC"
    fi
  else
    echo "  [SKIP] Add later: echo 'export GEMINI_API_KEY=\"your-key\"' >> ~/.zshrc"
  fi
fi

# ═══════════════════════════════════════════════
# Summary
# ═══════════════════════════════════════════════

echo ""
echo "  ╔══════════════════════════════════════╗"
echo "  ║       Installation Complete          ║"
echo "  ╚══════════════════════════════════════╝"
echo ""
echo "  Hooks:"
echo "    - Screenshot handler (resize + file + redirect)"
echo "    - Destructive command blocker (rm -rf, force push, sudo)"
echo "    - Context preservation (saves state before compaction)"
echo ""
echo "  Permissions:"
echo "    - Allow: all standard tools (no more prompting)"
echo "    - Deny: binary files, secrets, credentials, SSH keys"
echo ""
echo "  Rules:"
echo "    - Coding standards, git workflow, quality gates"
echo "    - Context management, binary handling, file hygiene"
echo "    - Screenshot management, full app audit"
echo "    - Gemini CLI orchestration"
echo "    - Capabilities manifest (Claude uses everything proactively)"
echo ""
echo "  Commands:"
echo "    - /audit <project> — full engineering audit"
echo "    - /gemini-review — delegate changes to Gemini for review"
echo ""
echo "  Settings:"
echo "    - Effort level: high"
echo "    - JSON schema for editor autocomplete"
echo ""
echo "  Restart Claude Code to activate."
echo "  Backup at: ${SETTINGS_FILE}.backup.*"
echo ""
