---
name: repo-flow:review-diff
description: Review a diff for real defects and convention drift, with line-level findings
argument-hint: range, PR number, or paths to review; defaults to unstaged changes
---

Use the **diff-review** skill.

Resolve the target first and echo the resolved command back before reviewing:

- Nothing given: `git diff` (unstaged changes)
- A base branch named: `git diff <base>...HEAD`
- A pull request number: `gh pr diff <number>`, or the GitHub MCP tools if this session has them
- A commit: `git show <sha> --format=`

Read `git diff --stat` for the shape, then open the changed files in full — a hunk read in isolation produces wrong findings. Locate the project's own rules in `AGENTS.md`, `.github/copilot-instructions.md`, `*.instructions.md`, or lint config, and review against those.

Report only defects you can anchor to a file and line, with the input or state that triggers them: correctness, security, data integrity, broken contracts, and missing tests for changed behavior. Suppress anything a linter would catch, naming taste, speculative refactors, and problems on lines the diff did not touch.

For a diff too large to finish in one pass, review it by directory cluster and state plainly which paths were not covered.

Format: verdict first, then findings in severity order with `file:line`, the trigger, and the smallest concrete fix. Close with what was read and what was not.
