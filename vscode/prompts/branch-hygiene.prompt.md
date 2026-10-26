---
name: repo-flow:branch-hygiene
description: Report stale and merged branches with the evidence for each, before anything is deleted
argument-hint: optional base branch, defaults to the repo default branch
---

Use the **branch-pr-lifecycle** skill.

Run `git fetch origin --prune` first, then resolve the default branch instead of assuming `main` or `master`. Collect state with:

- `git branch -vv`
- `git for-each-ref --sort=-committerdate --format='%(refname:short) %(committerdate:short) %(upstream:track)' refs/heads`
- `git remote -v`

Then, for every local branch:

1. Check commits unique to it versus the base with `git log <base>..<branch> --oneline`.
2. Confirm squash-merged work with `git cherry -v <base> <branch>`; a branch can look unmerged while its patches are already upstream.
3. Verify the remote branch still exists with `git ls-remote --heads origin <branch>`.
4. Note the last commit date.

Sort branches into safe to delete, needs confirmation, and keep, each with the specific evidence that put it there. An empty `git log base..branch` alone is not proof. List the exact delete commands but do not run them — deleting branches is destructive and needs my explicit approval.
