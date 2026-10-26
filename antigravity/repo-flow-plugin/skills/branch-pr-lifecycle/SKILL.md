---
name: branch-pr-lifecycle
description: "Manage Git branches and pull requests from creation to merge: name new branches, audit stale and merged branches, keep a branch current against its base, split a large change into a reviewable stack, and open or update a pull request. Use when starting feature work, cleaning up branches, rebasing onto main, reducing a big diff for reviewers, or writing a PR title and body. Triggers: 'new branch', 'delete stale branches', 'rebase on main', 'is this branch merged', 'open a PR', 'stack my branches'."
---

# Branch and PR Lifecycle

## Overview

Keep branches short-lived and cheap to review. The two failure modes are branches that outlive their purpose and diffs too large to reason about.

## Naming

Use `<type>/<slug>` where type is one of `feat`, `fix`, `chore`, `refactor`, `docs`, `test`, `perf`, and slug is a few hyphenated words describing the change, not the ticket number alone. Match the repo's existing prefix style before inventing one: check `git branch -a` and reuse the prevailing shape. Keep slugs under about 40 characters.

## Auditing branches

For each local branch, gather evidence before proposing deletion:

1. Is it merged into the default branch? `git branch --merged origin/<default>` reports it, but squash-merged and rebase-merged branches are absent from that list. Confirm with `git log origin/<default>..<branch> --oneline` — empty means nothing unique remains.
2. For squash-merged work, compare patch identity instead: `git cherry -v origin/<default> <branch>` prints `-` for commits already present upstream.
3. Does the remote still have it? Check `git ls-remote --heads origin <branch>`; a branch whose upstream vanished is tracked by `git branch -vv` as `: gone]`.
4. Was it touched recently? `git log -1 --format=%cd --date=short <branch>` gives the last commit date.

Delete only what passes, and present the list with its evidence for approval before running any delete. `git push origin --delete` and `git branch -D` are destructive; never batch them silently.

## Keeping a branch current

Rebase when the branch is shared by nobody but you and the base moved a little. Merge when others have pulled the branch or the history is long-lived. Prefer `git merge --no-rebase` updates on shared branches, and say which you chose and why. Always fetch first (`git fetch origin --prune`) so the base position is real.

## Splitting a large change

Order commits so each one compiles and leaves the tree in a working state, and so a reviewer can stop reading at any commit and still understand the series. Put mechanical changes — renames, formatting, moved files — in their own commits ahead of behavior changes, so `git log -p --stat` shows the interesting diff without the noise. Aim for one intent per commit; a PR that mixes a refactor with a fix should become two.

## Pull requests

Title: under 70 characters, same convention as commit summaries, names the outcome.

Body, in this order:

- Summary — what changes for a user or caller, in two or three sentences.
- Why — the problem, and any rejected alternative worth knowing.
- How it was verified — commands actually run, tests added, manual steps. State what was not verified.
- Reviewer notes — the file to start at, anything intentionally left out, follow-up work split into separate issues.

Write the body from the diff and commit log, not from memory. Use `gh pr create` for new requests and `gh pr view` / `gh pr diff` when updating an existing one; `gh` handles the authenticated request without a browser.

Do not open or push a PR unless the user asked for it. Prepare the branch and body, then confirm.
