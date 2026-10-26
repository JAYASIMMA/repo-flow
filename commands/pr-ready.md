---
description: Check a branch against pull request readiness and draft the title and body from the actual diff
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(gh:*), Read, Grep, Glob
argument-hint: [optional base branch to compare against]
---

## Context

- Current branch: !`git branch --show-current`
- Commits versus the base: !`git log --oneline @{u}..HEAD 2>/dev/null || git log --oneline -10`
- Diff shape: !`git diff --stat HEAD~5..HEAD 2>/dev/null | tail -20`
- Open PR on this branch: !`gh pr view --json number,title,state,url 2>/dev/null || echo "no pr"`

## Task

Use the branch-pr-lifecycle skill. Base branch: $ARGUMENTS

1. Establish the real merge base with `git merge-base` and read `git diff --stat <base>...HEAD` plus `git log --oneline <base>..HEAD`.
2. Score readiness against: single coherent scope, diff size a human can review, each commit leaving the tree working, tests covering changed behavior, no stray generated or secret files, base branch current.
3. Flag anything that should be split before review and say how.
4. Draft a title under 70 characters and a body with Summary, Why, Verification, and Reviewer notes. Verification must list commands actually run, not planned ones. Fill gaps by asking rather than inventing claims.
5. Do not push or open the PR. Show the draft and wait.
