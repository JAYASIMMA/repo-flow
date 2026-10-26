---
description: Read failing CI output and localise the break to a job, commit, test, or environment difference
allowed-tools: Bash(gh:*), Bash(git:*), Bash(npm:*), Bash(pnpm:*), Bash(yarn:*), Bash(cargo:*), Bash(go:*), Read, Grep
argument-hint: [optional run id, PR number, or workflow name]
---

## Context

- Current branch: !`git branch --show-current`
- Recent runs: !`gh run list --limit 10 2>/dev/null || echo "gh unavailable"`
- Checks on this branch: !`gh pr checks --failures 2>/dev/null || echo "no open pr"`

## Task

Use the ci-triage skill. Target: $ARGUMENTS

1. Identify the failing run and job. If `gh` is unavailable or unauthenticated, say so and ask for the log instead of guessing.
2. Pull only the failing step log with `gh run view <id> --log-failed`, then quote the first error line rather than the trailing wrapper.
3. Classify the failure — behind the base, environment drift, flaky, setup or dependency problem, or a real regression — and give the evidence for that classification.
4. Propose the smallest fix and the exact command that verifies it. Do not skip, delete, or weaken a test, and do not re-run repeatedly to call a deterministic failure flaky. Report anything you could not confirm.
