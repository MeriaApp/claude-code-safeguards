# Claude Code Safeguards

Defensive configuration for [Claude Code](https://claude.ai/code) that prevents common crashes, enforces quality, and adds smart file handling.

Built after hitting the **20MB request limit** by dropping screenshots into Claude Code — which crashes the session with no recovery. These safeguards make that impossible.

## What's Included

### Screenshot Hook (`hooks/process-screenshot.sh`)

A `PreToolUse` hook that intercepts image file reads before they hit the API:

1. **Resizes** retina screenshots to max 1400px wide (macOS `sips` or Linux ImageMagick)
2. **Files** them into `<project>/screenshots/` with timestamped names
3. **Blocks** the original read and tells Claude to use an Agent to parse the filed copy
4. **Auto-cleans** — keeps only the 50 most recent screenshots

This prevents the 20MB context blowup while keeping screenshots fully usable.

### Binary File Deny Rules

Hard-blocks reading these file types (they'd corrupt context or waste tokens):

- Video: `.mp4`, `.mov`, `.avi`
- Audio: `.mp3`, `.wav`
- Archives: `.zip`, `.tar.gz`, `.rar`, `.dmg`, `.iso`
- Design: `.psd`, `.ai`, `.sketch`

### Rules Files

Behavioral instructions that load automatically every session:

| Rule | What it does |
|------|-------------|
| `binary-file-handling.md` | Tells Claude the screenshot protocol and how to work with binary files via shell tools |
| `coding-standards.md` | Read before edit, minimal diffs, no placeholder code, no hardcoded secrets |
| `git-workflow.md` | Only commit when asked, stage specific files, never force push |
| `quality-standard.md` | Verification gate, risk control, production-grade on first write |
| `context-management.md` | When to compact, session hygiene, avoiding context overflow |

## Install

```bash
git clone https://github.com/MeriaApp/claude-code-safeguards.git
cd claude-code-safeguards
chmod +x install.sh
./install.sh
```

The installer:
- Copies hooks and rules to `~/.claude/`
- Merges deny rules into your existing `settings.json` (never overwrites)
- Backs up your current settings before any changes

**Requires:** `jq` (`brew install jq` on macOS, `apt install jq` on Linux)

Then restart Claude Code.

## How It Works

### The Problem

Dropping a screenshot into Claude Code triggers a `Read` tool call on the temp file. Retina Mac screenshots are 5-10MB each. Drop two or three and you blow past the 20MB API request limit — crashing the session with no way to recover (even double-Esc stops working).

### The Solution

```
You drop screenshot → Hook intercepts Read
                    → Resizes to 1400px wide
                    → Files to project/screenshots/20260319_170125.png
                    → Blocks original Read (exit 2)
                    → Tells Claude the filed path via stderr
                    → Claude spawns Agent to parse the filed screenshot
```

Exit code 2 is critical — it's the only code that actually blocks the tool call AND delivers feedback to Claude. Exit 1 is non-blocking (the read would still happen).

### Hook Exit Codes (Claude Code)

| Exit | Behavior |
|------|----------|
| `0` | Allow — tool call proceeds |
| `2` | Block — stderr shown to Claude as feedback |
| `1`, `3+` | Non-blocking error — logged to verbose mode only, tool call still proceeds |

## Verify It Works

After installing, drop any screenshot into Claude Code. You should see Claude:

1. Acknowledge the hook blocked the read
2. Reference the filed path in `screenshots/`
3. Spawn an Agent to read and describe the screenshot
4. Continue working with the screenshot content

## Customization

### Change max width

Edit `hooks/process-screenshot.sh`, line with `1400`:
```bash
if [ -n "$current_width" ] && [ "$current_width" -gt 1400 ] 2>/dev/null; then
  sips --resampleWidth 1400 ...
```

### Change screenshot retention

Edit the cleanup line (default keeps 50):
```bash
ls -t "$screenshots_dir"/* 2>/dev/null | tail -n +51 | ...
```

### Add more deny rules

Edit `~/.claude/settings.json`:
```json
"deny": [
  "Read(*.mp4)",
  "Read(*.your-extension)"
]
```

## Uninstall

```bash
# Restore settings backup
cp ~/.claude/settings.json.backup.* ~/.claude/settings.json

# Remove hook and rules
rm ~/.claude/hooks/process-screenshot.sh
rm ~/.claude/rules/binary-file-handling.md
rm ~/.claude/rules/coding-standards.md
rm ~/.claude/rules/git-workflow.md
rm ~/.claude/rules/quality-standard.md
rm ~/.claude/rules/context-management.md
```

## License

MIT
