# Context Management

## Preventing Context Overflow

- Run `/compact` proactively when context feels heavy — don't wait for auto-compaction
- Between unrelated tasks, use `/clear`
- Never read files >5MB directly — check size first with `stat` or `wc -c`, then use line ranges
- For large logs: `wc -l <file>` first, then read specific ranges with offset/limit
- If a Read is blocked by the screenshot hook, use an Agent to parse the filed version

## Session Hygiene

- Start each session by reading project state (CLAUDE.md, CONTEXT_STATE.md if it exists)
- Save important findings to files BEFORE context gets compressed — compressed context loses detail
- After significant changes, update CONTEXT_STATE.md (if the project uses one)
- Use `/compact "preserve: <key details>"` with explicit instructions on what to keep

## Avoiding Common Traps

- If stuck in a fix loop (same approach failing 2+ times), `/clear` and restart with a better prompt
- Don't read entire large directories — use Glob to find specific files, then read only what's needed
- Binary files (images, video, archives) are handled by hooks/deny rules — never try to read them raw
