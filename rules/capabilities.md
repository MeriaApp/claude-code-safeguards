# Available Capabilities

Use these proactively. Don't wait to be asked — if a capability fits the task, use it.

## Active Hooks (fire automatically)

- **Screenshot interceptor** (PreToolUse/Read) — resizes retina images, files to `project/screenshots/`, blocks oversized reads. If blocked, spawn an Agent to read the filed version at the path shown in stderr.
- **Destructive command blocker** (PreToolUse/Bash) — blocks `rm -rf`, `git push --force`, `sudo`, pipe-to-shell, disk ops. Suggests safer alternatives via stderr.
- **Context preservation** (PreCompact) — injects CONTEXT_STATE.md (or CLAUDE.md) into context before compaction so project state survives compression.

## Custom Commands (invoke with /)

- `/audit <project>` — full engineering audit with parallel agents. Scans code health, architecture, and platform compliance. Use after major changes or when asked for a health check.
- `/gemini-review` — delegate current git diff to Gemini CLI for code review. Use automatically after any change >100 lines or touching critical paths.

Create your own: add `.md` files to `~/.claude/commands/`. Filename becomes the command name.

## Built-in Commands to Use Proactively

- `/compact` — run every 20-30 minutes on deep sessions, or when context >70% (check with `/context`)
- `/compact "preserve: <details>"` — preserve specific context through compaction
- `/clear` — between unrelated tasks to start fresh
- `/context` — check context usage before it becomes a problem
- `/fast` — toggle faster output for bulk work
- `/loop <interval> <prompt>` — poll deploys, babysit PRs, run recurring checks
- `/simplify` — review recently changed code for quality and efficiency
- `/diff` — show what changed after multi-file edits

## Multi-AI Orchestration (requires Gemini CLI)

After changes >100 lines or touching architecture, delegate to Gemini CLI for review:
```bash
cd /tmp && git -C <project-root> diff | gemini -p "Review for bugs, edge cases, regressions" --output-format text 2>&1
```
Evaluate findings (~30% false positive rate). Apply valid ones. Build to confirm. See `gemini-orchestration.md` for full rules.

## Subagents

Spawn parallel agents for:
- **Audits** — code health, architecture, platform compliance in parallel
- **Research** — multiple independent topics simultaneously
- **Large refactors** — different files/concerns in parallel
- **Exploration** — use `subagent_type: "Explore"` for broad codebase questions

## Permission Summary

Full `Bash(*)` access. All standard tools unlocked. Binary files and credentials auto-denied by settings.json.
Per-project permission scoping available — add `.claude/settings.json` in any project root.
