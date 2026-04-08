# anthochamp/dev-toolbox Instructions

## Repository Overview

Shared developer toolbox for `anthochamp` projects. Provides reusable GitHub Actions workflows,
Renovate bot configuration presets, Lefthook git-hook presets, and Dart utility scripts that
other repositories consume by reference. There is no build step — all artifacts are YAML/JSON
config files and shell scripts used directly from source.

**Languages/Frameworks:**
- GitHub Actions (reusable `workflow_call` workflows)
- Renovate bot preset JSON
- Lefthook preset YAML
- Bash (Dart scripts)

## Project Structure

- `.github/workflows/` — Reusable workflows (all triggered via `workflow_call`)
  - `*-validate.yml` — Composite validation pipelines (lint + test) per platform
  - `*-publish.yml` — Publish pipelines per platform
  - `linter-*.yml` — Individual linter jobs (markdownlint, hadolint, shellcheck)
  - `util-*.yml` — Utility workflows (version tagging, Docker Hub sync)
- `config-presets/renovate/` — Renovate preset JSONs consumed with `github>anthochamp/dev-toolbox//config-presets/renovate/<name>`
- `config-presets/lefthook/` — Lefthook preset YAMLs consumed via `extends:` chains
- `scripts/dart/` — Bash helper scripts for Dart/Flutter projects

## Consumption Patterns

Workflows are called from consumer repos:

```yaml
jobs:
  validate:
    uses: anthochamp/dev-toolbox/.github/workflows/node-validate.yml@main
    with:
      node-package-manager: yarn
```

Renovate presets are extended in `renovate.json`:

```json
{ "extends": ["github>anthochamp/dev-toolbox//config-presets/renovate/base"] }
```

Lefthook presets are referenced via `extends:` in `lefthook.yml`:

```yaml
extends:
  - https://raw.githubusercontent.com/anthochamp/dev-toolbox/main/config-presets/lefthook/node-yarn.yaml
```

## Agent Guidance

- Lefthook configs use `extends:` chains — trace the chain (`node-yarn.yaml` → `common.yaml` → `base.yaml` + linter configs) to understand the full hook set.
- Renovate presets follow standard Renovate `extends` syntax; `base.json` is the root preset others build on.
- `*-validate.yml` workflows compose `common-lint.yml` plus platform-specific lint/test jobs.
- Pinned action SHAs in workflows are intentional — update both the SHA and the version comment together.
- The repo's own `renovate.json` extends `base.json` from itself (self-referencing preset).
