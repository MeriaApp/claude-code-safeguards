# Binary & Image File Handling

## Screenshots Dropped Into Chat

A PreToolUse hook (`~/.claude/hooks/process-screenshot.sh`) intercepts ALL image reads from non-screenshots locations. When triggered:

1. Resizes to max 1400px wide (retina screenshots are typically 2x)
2. Files into `<project-root>/screenshots/YYYYMMDD_HHMMSS.png`
3. Blocks the original read (exit 2 — stderr shown to you)
4. Auto-cleans: keeps only 50 most recent screenshots

**Your job when the hook fires:**
- Read the stderr message — it contains the filed path
- Spawn an Agent to read and fully parse the filed screenshot at the path provided
- Reference the filed path for all subsequent work
- NEVER retry reading the original temp path

**Passthrough (no hook):** Reads from any `*/screenshots/*` path go through normally.

## Non-Image Binary Files (video, audio, archives, design files)

Hard-denied in settings.json. Use shell tools:
- File info: `file <path>` or `mdls <path>`
- Archives: `unzip -l <file>` or `tar -tzf <file>`
- Video: `ffprobe -hide_banner <file> 2>&1 | head -20`

## Context Management

- Run `/compact` proactively when context feels heavy — don't wait for auto-compaction
- Between unrelated tasks, use `/clear`
- Never read files >5MB directly — use `head`, `tail`, or targeted line ranges
- For large logs: `wc -l <file>` first, then read specific ranges
