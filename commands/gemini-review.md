Delegate the current changes to Gemini CLI for code review.

1. Run `git diff` (or `git diff --cached` if staged) to capture all changes
2. If no diff, check recent commits with `git log -1 --format=%H` and diff against parent
3. Send to Gemini:
   ```bash
   cd /tmp && git -C <project-root> diff | gemini -p "Review this diff for bugs, edge cases, regressions, and security issues. List only real issues with file:line references. No style nits." --output-format text 2>&1
   ```
4. Evaluate each Gemini finding — expect ~30% false positives
5. Apply valid findings. Discard false positives with a brief reason.
6. Build and test to confirm no regressions
7. Report what was found, what was applied, and what was discarded
