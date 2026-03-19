# Gemini CLI Orchestration

Gemini CLI gives Claude a second brain — a different model with different strengths. Use it proactively.

## Setup

Install: `npm install -g @google/gemini-cli`
Auth: Get a free API key from https://aistudio.google.com/apikey and add to your shell:
```bash
echo 'export GEMINI_API_KEY="your-key-here"' >> ~/.zshrc  # or ~/.bashrc
source ~/.zshrc
```

## When Gemini Beats Claude

| Task | Why Gemini Wins |
|------|----------------|
| Code review after >100-line changes | 83% accuracy (vs 72% on Aider benchmark) |
| Full codebase scanning (>200K tokens) | 1M context window (5x Claude) |
| Bulk text processing | Gemini Flash is free (60 req/min) |
| Large file analysis (50K+ lines) | Fits without chunking |
| Second opinion on architecture | Different training data = different perspective |

## How to Call

```bash
# Basic (ALWAYS run from /tmp or project dir, not ~)
cd /tmp && gemini -p "your prompt" --output-format text 2>&1

# With Flash (free tier — use for bulk/cheap tasks)
cd /tmp && gemini -p "your prompt" -m gemini-2.5-flash --output-format text 2>&1

# Pipe a file for review
cd /tmp && cat /path/to/file | gemini -p "Review this for bugs" --output-format text 2>&1

# Pipe a git diff for code review
cd /path/to/project && git diff | gemini -p "Review this diff for bugs and edge cases. List only real issues." --output-format text 2>&1
```

## Rules

1. **Claude writes code. Gemini reviews.** Never apply Gemini's suggestions blindly — ~30% are false positives.
2. **Claude decides. Gemini advises.** When they disagree, Claude thinks harder — doesn't flip-flop.
3. **No secrets in prompts.** Never pass API keys or tokens to Gemini CLI.
4. **Max 2 delegations per task.** Over-delegation costs more in overhead than it saves.
5. **Run from /tmp, not ~.** Running from home directory causes .Trash permission errors.

## When NOT to Use Gemini

- Code writing (Claude is better)
- Architecture decisions (Claude decides)
- Copy/content writing (Claude's voice matching is better)
- Tasks Claude handles in <5 seconds (delegation overhead exceeds value)
- Small file analysis (<50K tokens)
