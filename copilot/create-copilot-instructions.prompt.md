---
name: Create/Reformat Copilot Instructions
description: Create or reformat .github/copilot-instructions.md following best practices
---

# Create/Reformat Copilot Instructions

You are helping create or reformat a `.github/copilot-instructions.md` file for a project.

## Goals

1. **Concise**: Only include project-specific information, not general knowledge
2. **Actionable**: Focus on commands and project structure
3. **Best Practice Structure**: Follow the standardized format below

## What NOT to Include

**Do not document general knowledge the AI already has:**

- Basic package manager commands (npm, yarn, pnpm basics)
- Standard Node.js/Python/etc. conventions
- How Git/GitHub Actions/CI generally works
- Language syntax or framework basics
- Generic testing/linting practices

**Only include:**

- **Project-specific** commands with non-standard flags or behaviors
- **Custom scripts** defined in package.json or Makefile
- **Project structure** that's unique to this codebase
- **Architecture decisions** that affect how to make changes
- **Special workflows** or tools specific to this project

## Standard Structure

```markdown
# Copilot Coding Agent Onboarding Instructions

## Repository Overview

Brief description (2-4 sentences):
- What the project does
- Main components/packages
- Target audience or use case

**Languages/Frameworks:**
- Primary language and version
- Key frameworks or tools
- Testing framework
- Linting/formatting tools

## Build, Test, and Validation

**Environment:** [Node version/Python version/etc.], [package manager], [special requirements]

**Commands (run from [repo root/specific dir]):**
- `command` — What it does (flags: `--flag`)
- `command2` — Brief description | Alternative: `alt-command`
- Testing: `test-cmd` (coverage: `test-cov`, watch: `test-watch`)

**Troubleshooting:** Common issue → solution | Another issue → another solution

## Project Structure

**[Monorepo/Module/Package] ([workspace tool if applicable]):**
- `directory/` — Purpose
- `another-dir/` — Purpose

**CI/CD:** [Tool] in `path/to/config`
- `workflow-name` — When it runs and what it does

**[Other sections if needed]:** Hooks, database migrations, etc.

## Agent Guidance

- Project-specific guidance that affects how the agent should work
- Architectural preferences unique to this project
- Where to find certain types of code
- What to reference when making changes

---

*Last updated: [date]*
```

## Execution Steps

### For New Projects

1. **Analyze the project:**
   - Read package.json / pyproject.toml / Cargo.toml / Makefile
   - Check for README.md, CONTRIBUTING.md
   - Identify package manager and version from lock files
   - Look for CI/CD configs (.github/workflows/, .gitlab-ci.yml, etc.)
   - Scan directory structure

2. **Extract key information:**
   - What does this project actually do?
   - What are the main commands to build/test/lint?
   - What's the directory structure?
   - Are there any special conventions or requirements?

3. **Create concise copilot-instructions.md:**
   - Repository overview (brief!)
   - Commands (compact format: `cmd — description | variant`)
   - Project structure (only unusual/important parts)
   - Agent guidance (only project-specific items)

### For Existing copilot-instructions.md

1. **Read the current file**

2. **Identify content to remove:**
   - General explanations of how tools work
   - Verbose command documentation ("Run this command to do X. For Y, use this flag...")
   - Redundant information already in training data
   - Generic best practices (these go in shared instruction files)

3. **Identify content to extract to shared files:**
   - Coding principles that apply across projects (→ quality-philosophy.instructions.md)
   - Language/framework conventions (→ language-specific .instructions.md)
   - Testing patterns (→ testing-best-practices.instructions.md)

4. **Reformat remaining content:**
   - Condense commands to compact format
   - Remove redundant sections
   - Reorganize into standard structure

5. **Present both:**
   - Show condensed copilot-instructions.md
   - List any new shared instruction files to create
   - Explain what was removed and why

## Command Format Examples

**❌ TOO VERBOSE:**

```markdown
### Build

Run `yarn build` from the repo root. This will build all workspace packages using their local build scripts. Each package uses TypeScript configs from `@ac-essentials/tsconfig`. If you encounter build errors, run `yarn clean` then `yarn build`.
```

**✅ CONCISE:**

```markdown
- `yarn build` — Build all packages (uses `@ac-essentials/tsconfig`)
```

**❌ TOO VERBOSE:**

```markdown
### Test

Run `yarn test` from the repo root to execute all tests using Vitest across all packages.
For coverage: `yarn test:coverage`
For watch mode: `yarn test:watch`
Individual packages can be tested with their own scripts, but prefer running from the root unless debugging a specific package.
```

**✅ CONCISE:**

```markdown
- `yarn test` — Test all | `yarn test:coverage` | `yarn test:watch`
```

## Example Output Quality

**Before (130 lines, verbose):**

```markdown
## Build Instructions

### Environment Setup
- **Node.js version:** Always use the version in `.nvmrc` (currently `24.11.1`).
- **Package manager:** Yarn v4. Run `yarn install` from the repo root before any build/test/lint steps.

### Build
- Run `yarn build` from the repo root. This will build all workspace packages...
[...many more paragraphs...]
```

**After (40 lines, concise):**

```markdown
## Build, Test, and Validation

**Environment:** Node.js version in `.nvmrc` (24.11.1), Yarn v4

**Commands:**
- `yarn install` — Install dependencies (run first)
- `yarn build` — Build all packages
- `yarn test` — Test all | `yarn test:coverage` | `yarn test:watch`

**Troubleshooting:** Build fails → `yarn clean && yarn build`
```

---

## Your Task

Analyze the current project and either:

1. **Create** a new `.github/copilot-instructions.md` following the structure above
2. **Reformat** the existing `.github/copilot-instructions.md` to be concise and follow best practices

Ask clarifying questions if needed, then proceed with the implementation.
