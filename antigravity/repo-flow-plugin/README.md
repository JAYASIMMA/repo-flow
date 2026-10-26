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

## Installing

Antigravity keeps plugins under `~/.gemini/config/plugins/`, alongside its skill locations at `~/.gemini/config/skills/` and `<workspace>/.agents/skills/`. Installing the gallery copy of this plugin is the supported route when it is listed. To place it by hand:

```bash
cp -r repo-flow-plugin ~/.gemini/config/plugins/
```

Restart Antigravity afterwards. Whether a hand-copied folder is loaded without an entry in `~/.gemini/config/config.json` has not been tested — every plugin observed on the machine used during development carried an `installedFrom` record naming the `antigravity-plugins-official` marketplace, so the gallery install is the reliable path and the manual copy is a convenience.

If you would rather not install anything globally, the same four skills work at workspace scope:

```bash
mkdir -p .agents/skills
cp -r skills/. .agents/skills/
```

## Why there are no command files

Antigravity invokes skills directly as `/skill-name`, so the four skills are also the four entry points. The five `.prompt.md` files that exist for VS Code have no counterpart here, and the `diff-review` skill is the adapted variant that reviews large diffs in directory batches — the Qoder plugin's `diff-reviewer` subagent is not part of this package.

## Publishing

Antigravity plugins are distributed through a marketplace repository whose layout matches the `marketplace.json` already present at the root of this repo (`.claude-plugin/marketplace.json`, listing `repo-flow` with `"source": "./"`). Submitting to `antigravity-plugins-official` is Google's curated process; publishing your own marketplace means hosting this repo and having users add it. The exact add-a-marketplace gesture in Antigravity was not verified during development.
