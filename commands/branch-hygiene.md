---
description: Report stale and merged branches with the evidence for each, before anything is deleted
allowed-tools: Bash(git branch:*), Bash(git log:*), Bash(git cherry:*), Bash(git ls-remote:*), Bash(git fetch:*), Read, Grep
argument-hint: [optional base branch, defaults to the repo default branch]
---

## Context

- Local branches with upstream state: !`git branch -vv`
- Branch dates: !`git for-each-ref --sort=-committerdate --format='%(refname:short) %(committerdate:short) %(upstream:track)' refs/heads`
- Remotes: !`git remote -v`

## Task

Use the branch-pr-lifecycle skill. Base branch: $ARGUMENTS

1. Refresh remote state first with `git fetch origin --prune`, then resolve the default branch rather than assuming `main` or `master`.
2. For every local branch, collect evidence: commits unique to it versus the base, `git cherry -v` output for squash-merged work, whether its upstream still exists, and its last commit date.
3. Sort into **safe to delete**, **needs confirmation**, and **keep**, each with the specific evidence that put it there. An empty `git log base..branch` alone is not proof — squash merges hide it.
4. List the exact delete commands but do not run them. Deleting branches is destructive and needs explicit approval.
