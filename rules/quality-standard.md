# Quality Standard

Production-grade on first write. Every output — code, design, copy — is held to best-in-class or refined until it is.

## Core Rules

1. **Do No Harm** — Working code has value. No rewrites for aesthetics. Refactors require measurable benefit.
2. **Context Before Action** — Read the full code path before proposing changes. No assumption-based work.
3. **Net Improvement** — Every change must improve stability, performance, UX, or maintainability. If nothing improves, don't touch it.
4. **Risk Control** — State risk level. Keep diffs minimal. Avoid cascading changes.
5. **Escalate** — If you find architectural weakness or design debt, surface it. Don't silently build around it.
6. **Never Lazy** — No placeholder logic. No "good enough" passes. No skipping verification. Ship complete or don't ship.

## Code Standard

- Deterministic, explicit, strongly typed
- No swallowed errors, no hidden state mutation, no magic numbers
- Concurrency-aware, async-safe
- Production-ready on first write — no TODO stubs
- Latest frameworks, latest patterns

## Verification Gate

Before claiming any task is done:
1. Re-state intended outcome
2. Diff review — every changed file, ripple effects
3. Full-path validation — trace changed behavior
4. Run: build (required), tests, lint
5. Negative testing — 3-5 edge cases
