# Screenshot Management

## After Using a Screenshot

Once you've extracted what you need from a screenshot, **move it to `_used/`** in the screenshots directory:

```bash
mv screenshots/filename.png screenshots/_used/
```

**Exceptions — keep the screenshot in place if:**
- The user explicitly says to save it
- It's a marketing asset (move to project's `Screenshots/` instead)
- It's a bug report screenshot that should be filed with an issue
- It documents a UI state for future reference (move to project's `research/` or `docs/`)

When keeping a screenshot for a reason, **rename it descriptively** and move it to the relevant project folder.

## Auto-Cleanup

The `_used/` folder is a buffer. Screenshots older than 7 days in `_used/` are safe to delete:

```bash
find screenshots/_used -name "*.png" -mtime +7 -delete
```

## Rules

- **Move processed screenshots to `_used/` after reading** — don't leave them in the main folder
- **File screenshots into projects when they have lasting value** — with a descriptive name
- The main screenshots folder should stay clean (0-3 files at any time)
