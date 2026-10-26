---
description: Audit staged changes and shape a well-formed commit message before anything is committed
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git add:*), Read, Grep, Glob
argument-hint: [optional intent describing the change]
---

## Context

- Status: !`git status --short`
- Staged stat: !`git diff --cached --stat`
- Unstaged stat: !`git diff --stat`
- Recent history for convention: !`git log --oneline -15`
- Current branch: !`git branch --show-current`

## Task

Use the commit-hygiene skill. Stated intent: $ARGUMENTS

1. Read `git diff --cached` in full. If nothing is staged, say so and stop — do not stage anything on your own.
2. Judge whether the staged set is one coherent change. If it contains unrelated work or files that should not be committed (secrets, local config, generated artifacts, machine-specific paths), name them and propose the split.
3. Draft a commit message that matches the prevailing style in the history above, derived from what the diff actually does.
4. Report the included files, the excluded files with reasons, the proposed message, and the exact `git commit` command. Do not run it; committing needs the user's go-ahead.
