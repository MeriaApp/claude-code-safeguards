# File Hygiene

## The `_review/` System

Every project can have a `_review/` folder — a staging area for suspected unused files.

### How It Works

1. When files appear unused, outdated, or misplaced — move them to `_review/`
2. Log every move in `_review/REVIEW_LOG.md` with date, original path, and reason
3. The developer reviews periodically and decides: delete or restore
4. If you need something back, check the log — it shows where everything came from

### REVIEW_LOG.md Format

```markdown
| Date | Item | Original Location | Reason | Status |
|------|------|-------------------|--------|--------|
| 2026-03-26 | old-plan.md | project root | Not referenced by any config | pending |
```

Status: `pending` → `deleted` or `restored`

### Rules

- **NEVER delete files directly** unless they're clearly build artifacts, caches, or duplicate files
- **Always log** before moving — no silent moves
- **Organize by category** in subfolders (`docs/`, `experiments/`, `ideas/`, etc.), not a flat dump
- **If you need something back**, restore it and update the log status to `restored`

## Screenshots & Test Artifacts

**NEVER write screenshots or test output to project roots.** Use these paths:

| Type | Location | Gitignored |
|------|----------|------------|
| Test screenshots | `<project>/test-artifacts/` | Yes |
| Hook-filed screenshots | `<project>/screenshots/` | Yes |
| Marketing screenshots | `<project>/Screenshots/` | No |

## Desktop / Home Directory

- Never write PNGs or test output to `~/` (home directory)
- Test scripts and tools must write to project `test-artifacts/`
- Desktop is for quick copy-paste staging, not storage
