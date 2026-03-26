Run a full engineering audit on $ARGUMENTS using the standard from `~/.claude/rules/full-app-audit.md`.

1. Read ALL source-of-truth files for the project (CLAUDE.md, README, CONTEXT_STATE.md, ROADMAP.md)
2. Spawn parallel Explore agents to scan:
   - **Code Health**: dead code, race conditions, memory leaks, error handling, state consistency, performance, concurrency safety
   - **Engineering Quality**: architecture violations, duplicated logic, fragile patterns, missing validation, tech debt
   - **Platform Compliance**: store guidelines, privacy, entitlements, accessibility, deprecated APIs
3. Cite every finding with `file_path:line_number`
4. Severity: P0 (crash/rejection/data loss), P1 (user-facing bugs), P2 (tech debt), P3 (improvements)
5. No false positives — read full code path before flagging
6. Save results to `<project>/ENGINEERING_AUDIT_<YYYY_MM>.md`

Output the structured report. Do not fix anything — audit only.
