# Change Log

All notable changes to the Repo Flow VS Code extension are documented here.

## [0.1.0] - 2026-10-26

Initial release.

### Added

- Four Agent Skills contributed through `chatSkills`: `commit-hygiene`, `branch-pr-lifecycle`, `diff-review`, `ci-triage`.
- Five slash commands contributed through `chatPromptFiles`: `/repo-flow:commit-check`, `/repo-flow:branch-hygiene`, `/repo-flow:pr-ready`, `/repo-flow:review-diff`, `/repo-flow:ci-triage`.
- `references/review-checklist.md` bundled with `diff-review` for per-language and per-change-type review prompts.

### Changed from the Qoder plugin

- `diff-review` replaces the Qoder-only `diff-reviewer` subagent with an explicit batched pass over directory clusters.
- Commands request git state at run time instead of relying on Qoder's pre-expanded context injection.
- Instruction-file discovery now includes `.github/copilot-instructions.md` and `*.instructions.md`.

### Removed

- The GitHub MCP connector. VS Code's Copilot Chat already contributes a GitHub server definition provider, so bundling a second one would duplicate it.
