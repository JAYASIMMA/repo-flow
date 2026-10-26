---
name: commit-hygiene
description: "Shape and audit git commits so each one is a single coherent change with an accurate message. Use when staging files, writing or amending a commit message, splitting an oversized commit, checking that a message matches its diff, or cleaning up a local commit history with fixup and autosquash. Triggers: 'commit this', 'write a commit message', 'is my commit good', 'split this commit', 'squash my WIP commits'."
---

# Commit Hygiene

## Overview

Make every commit one reviewable unit: a single intent, a message that states that intent, and nothing in the diff that contradicts it. Judge the commit before it is written, not after.

## Scope the change first

Run `git status --short` and `git diff --stat` (plus `git diff --cached --stat` if anything is staged) before touching the message. Ask of the whole set:

- Is there one intent here, or several? Unrelated edits — a refactor plus a bug fix, a formatting sweep plus a behavior change — are separate commits. Split them now with `git add -p` or `git stash` before it becomes a rebase problem.
- Does anything not belong: local-only config, `.env`, generated artifacts, debugger leftovers, absolute paths specific to one machine? Stage around it; never commit it.
- Is the change verifiable in one pass? A commit that cannot be reviewed in a few minutes is too large.

## Message rules

Derive the message from the diff, not from what the author intended to write.

- Summary line: imperative mood, under about 72 characters, no trailing period, no ticket ID where the subject belongs. "Retry the upload when the token expires", not "Fixed the upload thing".
- Prefer the repository's own convention when it is observable. Read `git log --oneline -20` first and match the prevailing style, including any Conventional Commits prefixes and the scope words other commits use. Do not impose a convention the repo does not already follow.
- Body only when the reason is not visible in the diff. Explain why, what was rejected, or a constraint. Skip a body for mechanical changes.
- Never claim something the diff does not do. If the message says "adds tests", verify tests were added.

## Pre-commit check

Before committing:

1. Confirm what is staged differs from what is merely changed — `git diff --cached --name-only`. Unstaged edits to a file that is already staged are left behind.
2. Look for files that were renamed without their partners moved, and for a lockfile changed without its manifest.
3. Reuse the repo's own checks when present (lint, format, `go vet`, type check) instead of asserting correctness. If a check is absent or slow, say which was run and which was not.
4. Report the exact command about to run and let the message be reviewed before it lands when the user has not already asked to commit.

## Repairing history safely

Prefer new commits over rewriting shared history.

- Local, unpushed commits: `git commit --fixup=<sha>` then `git rebase --autosquash --interactive <parent>` is the clean path to fold in a correction. Because interactive rebase needs a terminal, use `GIT_SEQUENCE_EDITOR=:` to accept the prepared todo list.
- Pushed commits: do not rewrite unless the user explicitly asks and knows the branch is theirs alone. Add a follow-up commit instead.
- Never run `git reset --hard`, `git push --force`, or `git clean -f` as a convenience. State the risk and ask first.
- No hooks should be bypassed. If a pre-commit hook fails, fix the cause; `--no-verify` hides it.

## Output

When reporting, give: the files included and any deliberately excluded, the proposed message, the checks actually run, and any split the user should consider before committing.
