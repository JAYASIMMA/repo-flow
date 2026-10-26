---
name: diff-review
description: "Review a Git diff for real defects and convention drift with file, line, and evidence for every finding. Use when asked to review code, check a pull request or branch before merge, review staged or unstaged changes, compare a branch to main, or audit a change for bugs, missing tests, and security problems. Triggers: 'review this diff', 'review my changes', 'check this PR', 'what broke here', 'review against main'."
---

# Diff Review

## Overview

Report only defects a reviewer would act on, each anchored to a file and line. A clean review is a valid outcome; a long list of preferences is not.

## Scope the diff

Default to unstaged changes. Resolve the target explicitly before reading code:

- Staged: `git diff --cached`
- Unstaged: `git diff`
- Against a base: `git diff <base>...HEAD` (three dots for the merge-base comparison reviewers expect)
- A pull request: `gh pr diff <number>` when the `gh` CLI is available, or the GitHub tools if the session has them
- One commit: `git show <sha> --format=`

Get the shape first with `git diff --stat <range>`, then read the changed hunks with enough context to judge them — `git diff -U25` or, better, open the full file. A hunk read in isolation produces wrong findings.

## Establish the project's rules

Find the instruction files the repository actually uses — `AGENTS.md`, `.github/copilot-instructions.md`, any `*.instructions.md`, `.editorconfig`, lint config, `CONTRIBUTING.md` — and review against those. Convention drift means a change that violates a rule written down, not a style you personally prefer. If no rule exists on a point, do not raise it.

## What counts as a finding

Report, in rough priority order:

- Correctness: logic errors, wrong branch conditions, off-by-one, unreachable cleanup, mutation of shared state, races and missing synchronisation, null or undefined paths that the new code can actually reach.
- Security: secrets or tokens committed, injection from untrusted input, authz or ownership checks skipped, unsafe deserialisation, path traversal from user-controlled filenames, widened permissions.
- Data integrity: irreversible migration, unbounded query or loop over user data, missing transaction around multi-write changes, delete without a guard.
- Contract: a signature, schema, or API response changed without updating its callers, tests, or docs.
- Tests: behavior changed with no test covering it, or a test that asserts the bug rather than the fix.

Do not report: formatting the linter would catch, naming taste, speculative refactors, "consider extracting", missing comments on self-evident code, or problems in untouched lines.

## Confidence filter

Before writing a finding, answer silently: can I name the input or state that produces the wrong outcome? If not, drop it. If yes but it depends on a caller you have not read, verify the caller first. Keep only findings you would defend in front of the author. Aim for the handful that matter rather than every possibility.

## Working through a large diff

Review in batches so nothing is skipped and nothing is guessed:

1. Group changed paths with `git diff --name-only <range>` and cluster by directory or subsystem.
2. Take the cluster with the most behavior change first, and read those files whole rather than as hunks.
3. For each changed symbol, search for its call sites and read the closest caller before judging it.
4. Hold findings until every cluster is covered, then sort by severity.

If the diff is too large to finish, say which paths were reviewed and which were not, rather than implying full coverage. Skip generated code, vendored dependencies, and snapshot files, and name that exclusion.

## Output

Lead with the verdict, then findings in severity order. Per finding:

```
**[High] One-line statement of the defect**
`path/to/file.ts:123` — what the code does, what it should do, and the input that triggers it.
Fix: the smallest concrete change.
```

Close with: what was reviewed (range and file count), what was checked and found sound, and what was not reviewed — generated files, unrunnable tests, untouched call sites. Never claim a review of code you did not read.

## Resources

`references/review-checklist.md` — per-language and per-change-type prompts. Load it when the diff is in a language you have not yet surveyed in this review, or when asked for a security-focused pass.
