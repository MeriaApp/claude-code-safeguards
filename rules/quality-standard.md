# Quality Standard

Production-grade on first write. No "good enough" passes.

## Core Rules

1. **Do No Harm** — Working code has value. No rewrites for aesthetics. Refactors require measurable benefit.
2. **Context Before Action** — Read the full code path before proposing changes. Trace parent containers, view hierarchies, and data flow before UI changes. No assumption-based work.
3. **Net Improvement** — Every change must improve stability, performance, UX, or maintainability. If nothing improves, don't touch it.
4. **Risk Control** — State risk level. Keep diffs minimal. Avoid cascading changes.
5. **Escalate** — If you find architectural weakness or design debt, surface it. Don't silently build around it.
6. **Never Lazy** — No placeholder logic. No skipping verification. Ship complete or don't ship.
7. **Fix Root Causes** — Never patch symptoms. Trace bugs to the source. If it takes longer, say so — but don't ship a band-aid.

## Verification Gate

Before claiming any task is done:
1. Re-state intended outcome
2. Diff review — every changed file, ripple effects
3. Full-path validation — trace changed behavior
4. Run: build (required), tests, lint
5. Self-review for bugs, regressions, edge cases
6. Don't ask "should I test?" — testing IS part of implementation
