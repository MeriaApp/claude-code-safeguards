# Context Management

## Preventing Context Overflow

- Run `/compact` proactively when context feels heavy — don't wait for auto-compaction
- Between unrelated tasks, use `/clear` to start fresh
- Never read files >5MB directly — check size first with `stat` or `wc -c`, then use line ranges
- For large logs: `wc -l <file>` first, then read specific ranges with offset/limit
- If a Read is blocked by the screenshot hook, use an Agent to parse the filed version

## Session Hygiene

- Start each session by reading project state (CLAUDE.md, any context/state files)
- Save important findings to files BEFORE context gets compressed — compressed context loses detail
- After significant changes, update project state files so the next session can pick up seamlessly
- Use `/compact "preserve: <key details>"` with explicit instructions on what to keep

## When to Start Fresh

- Switching to an unrelated topic — `/clear` or new terminal
- Context is >70% full
- Session has been running 30+ minutes with heavy tool output
- You see "Crunched/Summarized" — quality degrades after compaction
- About to drop images or large files
- Stuck in a fix loop (same approach failing 2+ times)

## Avoiding Common Traps

- Don't read entire large directories — use Glob to find specific files
- Binary files (images, video, archives) are handled by hooks/deny rules — never read raw
- If you `/rewind` to remove large files from context, pick "Restore conversation" (not code) to keep your code changes
