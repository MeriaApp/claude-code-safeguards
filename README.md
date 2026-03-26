# Claude Code Safeguards

Defensive configuration for [Claude Code](https://claude.ai/code) that prevents crashes, eliminates permission prompting, blocks destructive commands, adds Gemini CLI as a second brain, and installs reusable slash commands.

Built after hitting the **20MB request limit** by dropping screenshots into Claude Code — crashing the session with no recovery. These safeguards make that impossible.

## Install

**Paste this into Claude Code:**

```
Install the Claude Code safeguards from https://github.com/MeriaApp/claude-code-safeguards — clone to /tmp, run install.sh, then delete the clone.
```

That's it. Claude handles the rest.

**Or manually:**

```bash
git clone https://github.com/MeriaApp/claude-code-safeguards.git /tmp/claude-code-safeguards
cd /tmp/claude-code-safeguards && ./install.sh
rm -rf /tmp/claude-code-safeguards
```

**Requires:** `jq` (`brew install jq` / `apt install jq`)

## What's Included

### Hooks (3)

| Hook | Event | What it does |
|------|-------|-------------|
| `process-screenshot.sh` | PreToolUse/Read | Intercepts image reads, resizes retina screenshots to 1400px, files into `project/screenshots/`, blocks context blowup |
| `block-destructive-commands.sh` | PreToolUse/Bash | Blocks `rm -rf`, `git push --force`, `sudo`, pipe-to-shell attacks, disk-level ops |
| `save-context-before-compact.sh` | PreCompact | Injects CONTEXT_STATE.md into context before compression so project state survives |

### Commands (2)

Slash commands installed to `~/.claude/commands/` — invoke directly in Claude Code:

| Command | What it does |
|---------|-------------|
| `/audit <project>` | Full engineering audit with parallel agents — code health, architecture, platform compliance. Outputs structured report with P0-P3 severity. |
| `/gemini-review` | Delegates current git diff to Gemini CLI for code review. Evaluates findings, applies valid ones, discards false positives, builds to confirm. |

### Rules (9)

| Rule | What it does |
|------|-------------|
| `binary-file-handling.md` | Screenshot protocol, binary file alternatives, context limits |
| `coding-standards.md` | Read before edit, minimal diffs, no placeholders, no hardcoded secrets, no temp patches |
| `context-management.md` | When to `/clear`, when to `/compact`, session hygiene, when to start fresh |
| `file-hygiene.md` | `_review/` staging system for suspected trash, screenshot/test artifact paths, Desktop rules |
| `full-app-audit.md` | Structured audit framework — code health, engineering quality, platform compliance |
| `gemini-orchestration.md` | When/how to use Gemini CLI for code review and second opinions |
| `git-workflow.md` | Commit only when asked, stage specific files, never force push |
| `quality-standard.md` | Verification gate, risk control, root cause fixes, no band-aids |
| `screenshots.md` | Screenshot lifecycle — process, file to `_used/`, auto-cleanup after 7 days |

### Permissions

**Allow** (no more constant prompting):
- Bash, Read, Write, Edit, Glob, Grep, Agent, WebFetch, WebSearch

**Deny** (hard-blocked):
- Binary files: mp4, mov, avi, mkv, mp3, wav, flac, aac, zip, tar.gz, rar, 7z, dmg, iso
- Design files: psd, ai, sketch, fig
- Secrets: `~/.ssh/**`, `~/.gnupg/**`, `~/.aws/**`, `~/.azure/**`, `~/.kube/**`
- Credentials: `~/.docker/config.json`, `~/.npmrc`, `~/.pypirc`, `~/.git-credentials`, `~/.gem/credentials`
- Crypto keys: `*.pem`, `*.key`, `*.gpg`, `*.cert`, `*.crt`

### Settings

- `effortLevel: "high"` — better output quality
- `$schema` reference — editor autocomplete for settings.json

### Gemini CLI Setup (Interactive)

The installer offers to:
1. Install Gemini CLI (`npm install -g @google/gemini-cli`)
2. Open https://aistudio.google.com/apikey in your browser
3. Save your API key to your shell config

Gemini gives Claude a second brain — free code review, 1M context for large codebases, and a different perspective on architecture decisions.

## How the Screenshot Hook Works

```
You drop screenshot
  → Hook intercepts Read
  → Resizes to 1400px wide (retina = 2x)
  → Files to project/screenshots/20260319_170125.png
  → Blocks original Read (exit 2)
  → Tells Claude the filed path via stderr
  → Claude spawns Agent to parse the filed screenshot
```

**Hook exit codes (Claude Code):**

| Exit | Behavior |
|------|----------|
| `0` | Allow — tool call proceeds |
| `2` | Block — stderr shown to Claude as feedback |
| `1`, `3+` | Non-blocking error — logged only, tool call still proceeds |

## How the Destructive Command Hook Works

Blocks these patterns with clear feedback:

| Pattern | Block reason |
|---------|-------------|
| `rm -rf` / `rm -fr` | Suggests `trash` instead |
| `git push --force` | Prevents overwriting remote history |
| `git push origin main` | Requires feature branch |
| `sudo` | Asks user to run manually |
| `curl ... \| bash` | Download first, review, then execute |
| `mkfs`, `dd`, `fdisk` | Disk-level ops need manual confirmation |

## How the Commands Work

Commands are markdown files in `~/.claude/commands/`. The filename becomes the slash command name. Contents define the prompt Claude executes.

**`/audit <project>`** spawns parallel agents to scan code health, engineering quality, and platform compliance. Outputs a structured report with severity levels (P0-P3) and file:line citations.

**`/gemini-review`** captures your git diff, pipes it to Gemini CLI for an independent code review, then evaluates each finding (~30% are false positives), applies the valid ones, and builds to confirm no regressions.

Create your own commands by adding `.md` files to `~/.claude/commands/`.

## Customization

### Change screenshot max width

Edit `hooks/process-screenshot.sh`, find `1400`:
```bash
if [ "$current_width" -gt 1400 ]; then
```

### Change screenshot retention

Default keeps 50. Edit the cleanup line:
```bash
ls -t "$screenshots_dir"/* | tail -n +51 | xargs rm -f
```

### Add more deny rules

Edit `~/.claude/settings.json`:
```json
"deny": ["Read(*.your-extension)"]
```

### Add your own commands

Create a markdown file in `~/.claude/commands/`:
```bash
echo 'Do something useful with $ARGUMENTS' > ~/.claude/commands/my-command.md
```

Then invoke with `/my-command whatever args`.

### Disable a hook

Remove its entry from `~/.claude/settings.json` under `hooks.PreToolUse` or `hooks.PreCompact`.

## Uninstall

```bash
cp ~/.claude/settings.json.backup.* ~/.claude/settings.json
rm ~/.claude/hooks/process-screenshot.sh
rm ~/.claude/hooks/block-destructive-commands.sh
rm ~/.claude/hooks/save-context-before-compact.sh
rm ~/.claude/rules/binary-file-handling.md
rm ~/.claude/rules/coding-standards.md
rm ~/.claude/rules/context-management.md
rm ~/.claude/rules/file-hygiene.md
rm ~/.claude/rules/full-app-audit.md
rm ~/.claude/rules/gemini-orchestration.md
rm ~/.claude/rules/git-workflow.md
rm ~/.claude/rules/quality-standard.md
rm ~/.claude/rules/screenshots.md
rm ~/.claude/commands/audit.md
rm ~/.claude/commands/gemini-review.md
```

## Credits

Built by [Jesse Meria](https://jessemeria.com) and Claude. Inspired by [Trail of Bits](https://github.com/trailofbits/claude-code-config), [Disler's hooks mastery](https://github.com/disler/claude-code-hooks-mastery), and the [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) community.

## License

MIT
