---
name: ci-triage
description: "Turn failing CI output into a specific cause: which job failed, which test or step, whether the break is flaky, environmental, or a real regression, and the smallest change to make it pass. Use when a pipeline or workflow is red, a check fails with no local reproduction, a test passes locally but fails in CI, logs are truncated, or a build broke after a merge or dependency bump. Triggers: 'CI is red', 'why did this check fail', 'the test fails only in CI', 'flaky test', 'look at the Actions log'."
---

# CI Triage

## Overview

Find the smallest fact that explains the failure. Read the failing step's log before theorising, and reproduce locally before proposing a fix.

## Locate the failure

With GitHub Actions available through `gh`:

```bash
gh run list --branch "$(git branch --show-current)" --limit 10
gh run view <run-id>                      # job summary, which job failed
gh run view <run-id> --log-failed         # only failing steps
gh pr checks --failures                   # checks on an open PR
```

`--log-failed` is the default: full `--log` output is large and mostly noise. Record the job, the step name, and the first error line — the last line is usually a wrapper re-throwing an earlier cause.

Without the connector or CLI, ask for the log file or the pasted output rather than guessing at it.

## Classify before fixing

Answer these in order; each answer narrows the fix:

- **Did it ever pass?** Compare against the base branch. Red on `main` and green on the PR head means the branch is behind, not broken — update it.
- **Only in CI?** Environment drift: missing service, different locale or timezone, no `HOME`, no display, case-sensitive filesystem on Linux versus Windows or macOS, secret not exposed to fork PRs, path length or separator issues.
- **Passes when re-run?** Flaky. Look for execution order, shared state, timing assumptions, network calls in unit tests, and snapshot writes that race.
- **Fails at setup or install?** Dependency or registry problem, not the diff. Check lockfile consistency and the runner image tag.
- **One test, deterministic, on new code?** A real regression in the diff. Read the assertion, then the change that invalidated it.

## Bisect a regression on a long branch

Narrow by commit cheaply without a full bisect when the branch is short:

```bash
git log --oneline <base>..HEAD
```

Identify the commits touching the failing area with `git log --oneline <base>..HEAD -- <path>`. For a long range, `git bisect run <test command>` is worth automating; end with `git bisect reset`.

## Reproduce locally

Run the exact command the job ran, using the step's own line from the log rather than a remembered variant. Include the same environment variables and working directory. If the runner uses a container image, say so instead of claiming a local pass proves CI is wrong.

## Fix and report

Prefer the minimal change that addresses the cause. Never re-run a job three times to declare a deterministic failure flaky, and never skip, delete, or weaken a test to go green without naming it as a deliberate decision for the user to approve.

Report: the failing job and step, first error line, classification with the evidence behind it, the commit or change responsible when known, the fix, and the command that verifies it. If the log was unavailable, state what was needed and what was assumed.
