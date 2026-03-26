# Full App Audit

When asked for a "full app audit", "engineering audit", "code health audit", or "app audit", run this standard.

## Pre-Audit

1. Read ALL source-of-truth files (CLAUDE.md, README, CONTEXT_STATE.md, ROADMAP.md, etc.)
2. Identify the codebase root and all source directories

## Audit Dimensions

### 1. Code Health

- **Dead code**: Unused functions, unreachable branches, orphaned files, commented-out blocks
- **Race conditions**: Concurrent access to shared state, async mutations without isolation, cancellation gaps
- **Memory leaks**: Strong reference cycles, retained closures, missing cleanup
- **Error handling**: Swallowed errors, missing propagation, silent failures that leave bad state
- **State consistency**: Cache diverging from server, optimistic updates without rollback, stale data
- **Performance**: O(n^2) loops, unnecessary re-renders, heavy work on main thread
- **Concurrency safety**: Shared mutable state accessed from multiple threads

### 2. Engineering Quality

- **Architecture violations**: Code bypassing established patterns
- **Duplicated logic**: Same business logic in multiple places
- **Fragile patterns**: Timing-dependent behavior, order-dependent initialization, implicit assumptions
- **Missing validation**: Unsanitized user input reaching server, invalid data at boundaries
- **Tech debt**: Patterns that break at scale

### 3. Platform Compliance (whichever applies)

- **Store guidelines**: Subscription disclosure, privacy policy links, EULA
- **Privacy**: Data collection, tracking transparency, privacy manifest, required reason APIs
- **Permissions**: All declared ones used? Any missing?
- **Accessibility**: Screen readers, dynamic type/sizing, minimum tap targets, color contrast
- **Deprecation**: Use of deprecated APIs that could cause future rejection

## Execution Rules

1. **Use parallel agents** — spawn Explore agents for different directories/concerns
2. **Cite every finding** — `file_path:line_number` for every issue
3. **Severity levels**: P0 (crash/rejection/data loss), P1 (user-facing bugs), P2 (tech debt/risk), P3 (improvement)
4. **No false positives** — read the full code path before flagging
5. **Don't fix anything** — audit only, document findings
6. **Save results** — write to `<project>/ENGINEERING_AUDIT_<YYYY_MM>.md`

## Output Format

```markdown
# [Project] Engineering Audit — [Month Year]

## Summary
- P0: X findings
- P1: X findings
- P2: X findings
- P3: X findings

## P0 — Critical
### [Finding title]
**File:** `path:line`
**Issue:** [description]
**Impact:** [what breaks]
**Fix:** [one-line recommendation]

## P1 — High
...

## P2 — Medium
...

## P3 — Low
...
```
