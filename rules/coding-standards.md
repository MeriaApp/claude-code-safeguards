# Coding Standards

- Always read a file before editing it. Never edit blind.
- Prefer the smallest diff that achieves the goal.
- Don't refactor surrounding code unless asked.
- Don't add docstrings, comments, or type annotations to unchanged code.
- Don't add error handling for impossible scenarios.
- If something is unused, delete it completely. No _unused renames or backwards-compat shims.
- Never hardcode secrets, tokens, or credentials.
- Validate at system boundaries. Trust internal code.
- No placeholder logic, no TODO stubs — production-ready on first write.
- No temporary patches or band-aids. Find and fix root causes, not symptoms.
