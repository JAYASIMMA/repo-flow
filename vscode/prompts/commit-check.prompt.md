---
name: repo-flow:commit-check
description: Audit staged changes and shape a well-formed commit message before anything is committed
argument-hint: optional intent describing the change
---

Use the **commit-hygiene** skill.

Gather the current state by running these yourself and reading the output:

- `git status --short`
- `git diff --cached --stat` and `git diff --stat`
- `git branch --show-current`
- `git log --oneline -15` for the project's prevailing message style

Then:

1. Read `git diff --cached` in full. If nothing is staged, say so and stop without staging anything.
2. Judge whether the staged set is one coherent change. If it contains unrelated work, or files that should not be committed — secrets, local config, generated artifacts, machine-specific paths — name them and propose the split.
3. Draft a commit message in the style the history shows, derived from what the diff actually does.
4. Report included files, excluded files with reasons, the proposed message, and the exact `git commit` command. Do not run it; committing needs my go-ahead.

Any intent I typed after this command is the stated goal of the change; reconcile it against the diff rather than trusting it.
