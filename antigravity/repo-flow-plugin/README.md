# Repo Flow for Antigravity

The Antigravity packaging of the repo-flow workflow: four Agent Skills in the shape this app reads natively.

## Contents

```
repo-flow-plugin/
├── plugin.json          name, displayName, version, description, logo, author, repository, license, keywords
├── assets/logo.png      256x256 RGBA icon, same git-graph geometry as the Qoder avatar
└── skills/
    ├── commit-hygiene/SKILL.md
    ├── branch-pr-lifecycle/SKILL.md
    ├── diff-review/SKILL.md
    │   └── references/review-checklist.md
    └── ci-triage/SKILL.md
```

## Using it

Antigravity activates a skill when your request matches its `description`, and you can also invoke one directly by name:

```
/commit-hygiene        stage these changes and write the commit message
/branch-pr-lifecycle   which local branches are safe to delete?
/diff-review           review the diff against main
/ci-triage             why is this check failing?
```

The everyday pattern is to say what you want in plain language — "review the diff against main before I push" — and let the agent pull in `diff-review`. Plugin skills may be namespaced by Antigravity if a name collides with another customization.

Repo Flow does not commit, push, open a pull request, or delete a branch on its own. Destructive steps are always proposed with their evidence, for you to approve.

## Installing

Antigravity loads customizations from **customization roots**: `.agents/` inside a project and `~/.gemini/config/` globally. A plugin must sit under a `plugins/` folder inside one of those roots, and `plugins.json` in the root registers additional plugin directories. The layout here already satisfies that: `plugin.json` plus a `skills/` folder of `<skill>/SKILL.md` directories.

Use the script one level up, which copies the plugin into the global root and registers it:

```powershell
.\install-antigravity.ps1              # install
.\install-antigravity.ps1 -Uninstall   # roll back
```

It writes `~/.gemini/config/plugins.json` as:

```json
{ "entries": [ { "path": "~/.gemini/config/plugins", "include_only": ["^repo-flow-plugin$"] } ] }
```

Three deliberate choices there. The path names the folder **containing** plugins, because `include_only` matches directory names — pointing it at the plugin folder itself would scan one level too deep. `include_only` is scoped so the gallery plugins already in that folder are not re-registered. And `plugins.json` is the documented user-facing file; `~/.gemini/config/config.json` belongs to the app and records gallery installs as `installedFrom`, so the script does not touch it. Output is written without a UTF-8 BOM, which PowerShell's `Set-Content -Encoding utf8` would otherwise add and which breaks strict JSON parsers.

Restart Antigravity after installing. Uninstall keeps a timestamped copy of the folder out of caution — delete it yourself afterwards, since leaving it inside a `plugins/` root is litter.

Workspace scope instead, with no global change:

```bash
mkdir -p .agents/plugins
cp -r repo-flow-plugin .agents/plugins/
```

Or just skills, no plugin wrapper at all — this repo's own `.agents/skills/` is auto-discovered when you open it in Antigravity:

```bash
mkdir -p .agents/skills
cp -r skills/. .agents/skills/
```

## Why there are no command files

Antigravity invokes skills directly as `/skill-name`, so the four skills are also the four entry points. The five `.prompt.md` files that exist for VS Code have no counterpart here, and the `diff-review` skill is the adapted variant that reviews large diffs in directory batches — the Qoder plugin's `diff-reviewer` subagent is not part of this package.

## Publishing

Antigravity plugins are distributed through a marketplace repository whose layout matches the `marketplace.json` already present at the root of this repo (`.claude-plugin/marketplace.json`, listing `repo-flow` with `"source": "./"`). Submitting to `antigravity-plugins-official` is Google's curated process; publishing your own marketplace means hosting this repo and having users add it. The exact add-a-marketplace gesture in Antigravity was not verified during development.
