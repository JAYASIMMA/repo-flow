# Repo Flow

A Qoder plugin that codifies the everyday repository workflow: commits that stay coherent, branches that do not outlive their purpose, diffs reviewed for real defects, and red pipelines narrowed to a cause.

## What it ships

Four Skills, loaded automatically when a task matches:

| Skill | Covers |
| --- | --- |
| `commit-hygiene` | Scoping a change, message conventions read from history, safe history repair |
| `branch-pr-lifecycle` | Branch naming, stale-branch auditing with evidence, keeping a branch current, splitting a stack, PR title and body |
| `diff-review` | Diff scoping, project-convention drift, confidence filtering, finding format |
| `ci-triage` | Locating the failing step, classifying flaky versus environmental versus regression, reproducing locally |

Five commands:

| Command | Does |
| --- | --- |
| `/repo-flow:commit-check` | Audits staged changes and drafts the commit message; does not commit |
| `/repo-flow:branch-hygiene` | Lists deletable branches with the evidence; does not delete |
| `/repo-flow:pr-ready` | Scores branch readiness and drafts the PR body |
| `/repo-flow:review-diff` | Reviews a range, delegating large diffs to the reviewer subagent |
| `/repo-flow:ci-triage` | Reads failing check logs and localises the break |

One subagent, `diff-reviewer`, for second passes over diffs larger than roughly 400 lines or ten files, so the reading cost stays out of the main conversation.

One Connector: the GitHub remote MCP server, used for pull request detail and check-run logs.

## Marketplace entry

This directory is also a self-contained marketplace, following the single-plugin pattern used by `chrome-devtools-mcp`. The manifest is identical in both locations:

```
.claude-plugin/marketplace.json
.qoder-plugin/marketplace.json
```

```json
{
  "name": "jayasimma-plugins",
  "version": "0.1.0",
  "repository": "https://github.com/JAYASIMMA/repo-flow",
  "owner": {
    "name": "Jayasimma",
    "email": "137266557+JAYASIMMA@users.noreply.github.com"
  },
  "plugins": [
    { "name": "repo-flow", "source": "./" }
  ]
}
```

The `repository` in both manifests, and the `homepage` and `repository` in `plugin.json`, all point at `https://github.com/JAYASIMMA/repo-flow`. The marketplace identifier itself is lowercase `jayasimma-plugins` because plugin and marketplace names are validated as hyphen-case; the installed plugin key follows it as `repo-flow@jayasimma-plugins`.

## The GitHub connector

`.mcp.json` points at the remote server:

```json
{
  "mcpServers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/",
      "headers": { "Authorization": "Bearer ${GITHUB_PERSONAL_ACCESS_TOKEN}" }
    }
  }
}
```

Set `GITHUB_PERSONAL_ACCESS_TOKEN` to a fine-grained token scoped to the repositories you work in, with read access to contents and pull requests, and write only where you want the plugin to comment or open requests. The remote server also supports one-click OAuth in clients that offer it; prefer that over a static token if your Qoder build exposes the option.

Two caveats worth knowing before you rely on this:

- Header interpolation of `${VAR}` is written the way Qoder documents env expansion for MCP config, but the two sample connectors shipped in the marketplace plugins examined during development used no headers at all. If the connector fails to authenticate, put the token in directly through Qoder's MCP settings instead of editing this file, and never commit the result.
- Everything else in this plugin works without the connector. `ci-triage` and `pr-ready` fall back to plain `git` and the `gh` CLI, and will ask for a log rather than guess when neither is available.

## Installing

Two routes.

**From a marketplace.** Push this directory as a git repository, then add it as a marketplace in Qoder and install `repo-flow` from that list. The install is recorded by the app, so you edit no JSON yourself.

**By hand.** Copy or clone this directory to `~/.qoder/plugins/repo-flow`, then register it.

In `~/.qoder/plugins/installed_plugins_v2.json`, add under `plugins`:

```json
"repo-flow@jayasimma-plugins": [
  {
    "scope": "user",
    "installPath": "<absolute path to this directory>",
    "version": "0.1.0",
    "installedAt": "<ISO timestamp>",
    "lastUpdated": "<ISO timestamp>",
    "displayName": "Repo Flow"
  }
]
```

In `~/.qoder/settings.json`, add the same key under `enabledPlugins`:

```json
"repo-flow@jayasimma-plugins": true
```

The suffix is the marketplace name from `marketplace.json`. Keep both files consistent; a key that appears in only one leaves the plugin registered but disabled, or enabled but unregistered.

Restart the session. Skills trigger on their own; commands appear as `/repo-flow:<name>`.

## Layout

```
repo-flow/
├── .qoder-plugin/plugin.json       manifest: metadata, commands, skills, agents, mcpServers, interface
├── .qoder-plugin/marketplace.json  marketplace entry (Qoder-native location)
├── .claude-plugin/marketplace.json marketplace entry (Claude-compatible location, identical content)
├── .mcp.json                       GitHub remote MCP connector
├── assets/avatar.svg               logo, composer icon
├── skills/<name>/SKILL.md          Qoder skills; diff-review here keeps its subagent
├── commands/<name>.md              five Qoder slash commands
├── agents/diff-reviewer.md         reviewer subagent (Qoder only)
├── .agents/skills/<name>/SKILL.md  portable copy for Antigravity and VS Code workspaces
├── antigravity/repo-flow-plugin/   Antigravity plugin: plugin.json, assets/logo.png, skills/
└── vscode/                         VS Code extension: package.json, skills/, prompts/, media/icon.png
```

Four surfaces, one workflow: Qoder plugin (this directory), VS Code extension (`vscode/`), Antigravity plugin (`antigravity/repo-flow-plugin/`), and a tool-neutral workspace folder (`.agents/skills/`).

Three skill trees, deliberately: `skills/` is the Qoder original with subagent delegation, `vscode/skills/` is the adapted port with no subagent, and `.agents/skills/` is byte-identical to the adapted port so one folder serves both Antigravity and a VS Code workspace. The validator asserts those relationships instead of trusting them.

## Using it in Antigravity and other agents

Antigravity loads customizations from a **customization root**: `.agents/` in a project, or `~/.gemini/config/` globally. Skills belong in `<root>/skills/<name>/SKILL.md` — so the `.agents/skills/` folder here is already in the documented shape — and plugins belong in `<root>/plugins/<name>/` with a `plugin.json`, optionally registered by a `plugins.json` in that root. Frontmatter needs `name` and `description`, which every file here already carries, and a loaded skill is invocable as `/skill-name` as well as activated from its description.

Install the plugin globally on this machine:

```powershell
antigravity\install-antigravity.ps1            # copy into the root + register
antigravity\install-antigravity.ps1 -Uninstall # roll back
```

Workspace-scoped instead, with no global change:

```bash
mkdir -p .agents/skills
cp -r <this-repo>/.agents/skills/. .agents/skills/
```

The five Qoder commands have no Antigravity equivalent and do not need one: the skills themselves are slash-invocable there. Rules files (`AGENTS.md`, `GEMINI.md`, or `.agents/rules/*.md`) are a separate mechanism and are deliberately not shipped here, so this plugin does not silently rewrite a project's own agent rules.

`.agents/skills/` is also read by VS Code, and `.github/skills/` and `.claude/skills/` are recognized too — so the same folder works across those tools without the extension. Use the `vscode/` extension when you want the skills available in *every* workspace instead of per-repo.

One collision to avoid: skill names must be unique per VS Code session. If you open *this* repository in VS Code with the extension also installed, `commit-hygiene` arrives twice — once from the extension, once from the workspace. Pick one surface per project; the extension for everyday work, the folder for repo-local overrides.

## Publishing to the marketplace

The git repository, `owner.email`, the mirrored `repository` and `homepage` fields, and the `LICENSE` holder are all in place. What remains:

- Fill at least one `interface.screenshots` entry in `plugin.json`; the field is an empty array.
- If you submit through Qoder's own marketplace instead of distributing this repo directly, the app writes the install record itself, and the key becomes `repo-flow@qoder-marketplace` with a server-issued `marketId`.

`category`, `tags`, `descriptionZh`, `brandColor`, and `defaultPrompt` are already filled to match the shape of existing marketplace plugins.

## Also in this repository

`vscode/` holds a companion VS Code extension that ships the same workflow to GitHub Copilot as Agent Skills and `.prompt.md` slash commands, packaged to `repo-flow-0.1.0.vsix` by `vsce`. See [vscode/README.md](vscode/README.md) for what it changes and why — notably that `diff-review` there has no subagent to delegate to, and the GitHub MCP connector is intentionally left out because VS Code already contributes one.

`antigravity/repo-flow-plugin/` holds the Google Antigravity packaging: a `plugin.json` in the shape their installed plugins use, the same 256px logo, and the four skills. No command files — Antigravity invokes skills as `/skill-name`. See [antigravity/repo-flow-plugin/README.md](antigravity/repo-flow-plugin/README.md).

## Design rules these skills follow

Every finding, message, and command output must be anchored to something the tool actually read. Commands that destroy work — branch deletes, force pushes, history rewrites — are always proposed, never run silently. A review that returns nothing is a valid result, so the skills bias toward suppressing preference-based comments. And nothing claims a check passed that was not run.

## License

MIT. See [LICENSE](LICENSE).
