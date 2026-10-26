---
name: repo-flow:pr-ready
description: Check a branch against pull request readiness and draft the title and body from the actual diff
argument-hint: optional base branch to compare against
---

Use the **branch-pr-lifecycle** skill.

Establish the real merge base with `git merge-base <base> HEAD`, then read `git diff --stat <base>...HEAD` and `git log --oneline <base>..HEAD`. If `gh` is available, check for an existing PR with `gh pr view --json number,title,state,url`.

Score readiness against each of these and give a verdict per item:

- One coherent scope, not several changes bundled together
- A diff size a human can actually review
- Every commit leaves the tree in a working state
- Tests cover the behavior that changed
- No stray generated files, local config, or secrets
- The branch is current with its base

Flag anything that should be split before review and say how.

Then draft a title under 70 characters and a body with Summary, Why, Verification, and Reviewer notes. Verification must list commands that were genuinely run, not planned ones — if nothing was run, say so instead of inventing it. Fill any gap by asking me, not by guessing.

Do not push or open the PR. Show the draft and wait.
