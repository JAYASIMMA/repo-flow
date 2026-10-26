---
name: repo-flow:ci-triage
description: Read failing CI output and localise the break to a job, commit, test, or environment difference
argument-hint: optional run id, PR number, or workflow name
---

Use the **ci-triage** skill.

Find the failing run and job:

- `gh run list --limit 10`
- `gh run view <run-id> --log-failed` — failing steps only, never the whole log
- `gh pr checks --failures` for an open PR

If `gh` is missing or unauthenticated and no GitHub MCP tools are available, say so and ask me for the log rather than guessing at a cause. Quote the first error line; the last line is usually a wrapper re-throwing an earlier cause.

Classify before proposing anything, and give the evidence for the classification:

- Red on the base too, or the branch is simply behind — update the branch rather than "fixing" code
- Only in CI — environment drift: missing service, locale, timezone, case-sensitive filesystem, path separators, secrets unavailable to fork PRs
- Passes when re-run — flaky: look for ordering, shared state, timing assumptions, network in unit tests
- Fails during setup or install — dependency or registry problem, not the diff
- One deterministic test on new code — a real regression in the diff

For a regression on a long branch, narrow with `git log --oneline <base>..HEAD -- <path>` before suggesting a bisect.

Reproduce locally with the exact command from the log, same environment and working directory. Propose the smallest fix and the command that verifies it. Do not skip, delete, or weaken a test to go green, and do not re-run a job repeatedly to relabel a deterministic failure as flaky — if either is genuinely the right call, name it as a decision for me to approve.
