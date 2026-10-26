# Repo Flow for VS Code

Agent Skills and slash commands for GitHub Copilot in VS Code, covering the repository workflow: commits that stay coherent, branches that do not outlive their purpose, diffs reviewed for real defects, and red pipelines narrowed to a cause.

This folder is the VS Code extension. The directory above it is the [Qoder plugin](../README.md); the two ship the same workflow through different packaging.

## What it contributes

Four Agent Skills, loaded on demand when your request matches their description:

| Skill | Covers |
| --- | --- |
| `commit-hygiene` | Scoping a change, message conventions read from history, safe history repair |
| `branch-pr-lifecycle` | Branch naming, stale-branch auditing with evidence, keeping a branch current, splitting a stack, PR title and body |
| `diff-review` | Diff scoping, project-convention drift, confidence filtering, batched reading of large diffs, finding format |
| `ci-triage` | Locating the failing step, classifying flaky versus environmental versus regression, reproducing locally |

Five slash commands, namespaced so they do not collide with anything else you have installed:

| Command | Does |
| --- | --- |
| `/repo-flow:commit-check` | Audits staged changes and drafts the message; does not commit |
| `/repo-flow:branch-hygiene` | Lists deletable branches with evidence; does not delete |
| `/repo-flow:pr-ready` | Scores branch readiness and drafts the PR body |
| `/repo-flow:review-diff` | Reviews a range, in batches if it is too large for one pass |
| `/repo-flow:ci-triage` | Reads failing check output and localises the break |

Skills trigger from their description; commands are explicit. Both are declarative contributions, so the extension contains no code and has no activation cost.

## Installing

From the built VSIX:

```bash
code --install-extension repo-flow-0.1.0.vsix
```

Or, without packaging anything, drop the skill folders into a workspace and VS Code discovers them:

```
<repo>/.github/skills/commit-hygiene/SKILL.md
```

User-level skills are read from `~/.copilot/skills/`.

## GitHub access

No MCP server is bundled. VS Code's Copilot Chat already contributes a GitHub `mcpServerDefinitionProviders` entry, so the GitHub tools come from there — enable GitHub in the Tools tab rather than adding a second connection. The `gh` CLI works too, and every command falls back to plain `git` when neither is available, asking for the log instead of inventing one.

## Requirements

`engines.vscode` is `^1.143.0`. That floor is evidence-based, not convenience: `chatSkills` and `chatPromptFiles` were confirmed registered in the 1.143.1 workbench bundle, and no earlier version was checked. On an older VS Code the contributions are simply unrecognized and the extension does nothing.

## Differences from the Qoder plugin

Deliberate, and worth knowing before you expect parity:

- **No subagent.** Qoder ships a `diff-reviewer` subagent for large diffs. `diff-review` here replaces that with an explicit batched pass by directory cluster, so a VS Code user still gets full coverage rather than a dangling instruction.
- **No context injection.** Qoder command files can pre-expand `!`git status`` before the model reads them. Prompt files here ask the agent to run the commands itself.
- **Different instruction sources.** This skill reads `.github/copilot-instructions.md` and `*.instructions.md` alongside `AGENTS.md`, because that is where VS Code projects keep their rules.
- **Three verbatim copies.** `commit-hygiene`, `branch-pr-lifecycle`, `ci-triage` and the review checklist are byte-for-byte copies of the Qoder originals. Editing one side does not update the other; keep them in sync or the two products will drift.

## Building

```bash
npm install -g @vscode/vsce
cd vscode
vsce package
```

`vsce package` produces `repo-flow-<version>.vsix`. To publish, create a publisher in the Marketplace, set `publisher` in `package.json` to match it, then:

```bash
vsce publish -p <PERSONAL_ACCESS_TOKEN>
```

The `publisher` value in `package.json` is a placeholder until you create the real publisher ID. An icon is not declared; add `"icon": "./media/icon.png"` with a 128x128-or-larger PNG before publishing if you want a listing icon.

## License

MIT. See [LICENSE](LICENSE).
