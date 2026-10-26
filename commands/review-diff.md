---
description: Review a diff for real defects and convention drift, with line-level findings
allowed-tools: Bash(git diff:*), Bash(git log:*), Bash(gh pr diff:*), Read, Grep, Glob, Agent
argument-hint: [range, PR number, or paths to review; defaults to unstaged changes]
---

## Context

- Current branch: !`git branch --show-current`
- Diff shape: !`git diff --stat | tail -30`
- Staged shape: !`git diff --cached --stat | tail -20`

## Task

Use the diff-review skill. Target: $ARGUMENTS

1. Resolve the range. Default to unstaged changes; use `git diff <base>...HEAD` when a base is named, `gh pr diff <number>` for a pull request, `git show <sha>` for a commit. Echo the resolved command back before reviewing.
2. If the diff exceeds roughly 400 lines or ten files, delegate to the `repo-flow:diff-reviewer` subagent with the exact range command, the project instruction files to honor, and the paths to skip. Otherwise review inline.
3. Read every cited line yourself before relaying a finding. Drop findings the code does not support.
4. Report the verdict, findings in severity order with `file:line`, trigger, and the smallest fix, then a coverage note stating what was read and what was not. Keep the review silent on style the linter already covers.
