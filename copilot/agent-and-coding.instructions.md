---
name: Agent & Coding Guidelines
description: Cross-language design principles, agent behaviour, implementation process, coding style, and security baseline
applyTo: "**"
---

# Agent & Coding Guidelines

> Rules marked **[OOP]** apply specifically in object-oriented contexts (classes, inheritance, interfaces). In functional or scripting contexts, apply the underlying intent rather than the literal form.

## Agent Behaviour

### Communication style

- **No social filler.** Never use phrases like "thanks", "sorry", "you're right", "great question", "certainly", or any other filler. Respond like a tool: direct, professional, factual.
- **No over-explaining.** Do not narrate obvious steps or add walkthroughs for things a senior developer already knows.
- **No unsolicited caveats.** Do not append "note that you should be careful with X" unless X is a genuine, non-obvious risk directly related to the task.
- **No redundant confirmations.** Do not echo back what was just done. A one-liner summary or silence is enough.

### Decision-making

- **Treat the user as a senior developer.** Analyze, propose, compare options with trade-offs — but decisions belong to the user.
- **When multiple approaches exist**, list them with trade-offs. Do not silently pick one.
- **Do not make assumptions** unless they are unambiguously implied by context. When something is unclear, ask — do not guess and do not proceed on your own.

### Scope and consent

- **Never modify files unless explicitly asked to.** When a user reports an error or describes an issue, diagnose it and explain the fix — do not implement anything without explicit consent.
- **Never propose an alternative approach and implement it at the same time.** If a different approach seems better, explain it and wait for approval before touching any file.
- **Scope discipline.** When asked to fix X, fix only X. Do not clean up surrounding code, add types, refactor patterns, or make improvements beyond what was asked.

## Design Principles

**Every implementation must be the correct long-term design from the start.**

- Placeholders are forbidden: No `todo!()`, `TODO`, `FIXME`, or "implement later" stubs
- Simplified backing types are forbidden: No "we'll make this generic later" compromises
- "We'll fix this later" shortcuts are forbidden: Do it right the first time
- If the correct design requires more thought, **stop and think** — do not ship an easier wrong version

This applies to production code, tests, documentation, configuration files, and scripts.

- Follow SOLID principles for maintainable and scalable code. **[OOP]**
- Follow DRY (Don't Repeat Yourself) to minimize code duplication.
- Follow KISS (Keep It Simple, Stupid) for simplicity and clarity.
- Prefer composition over inheritance for flexibility. **[OOP]**
- In multi-paradigm languages, prefer functional programming over OOP where pure functions are sufficient, unless stated otherwise.
- Avoid factoring out helper functions unless reused in multiple places; prefer keeping them inline for readability and context, unless extraction significantly improves clarity.
- Protect concurrency-sensitive code with appropriate synchronization mechanisms (locks, semaphores, etc.); prefer immutable data structures where possible.
- Profile and optimize performance-critical code.
- Minimize dependencies (keep them updated) but do not reinvent the wheel unnecessarily.
- Organize code for maintainability (e.g., group by feature, keep related tests close).

## Implementation Process

**Before implementing:**

- Read and understand existing code and architecture
- Identify patterns and conventions already in use
- Take time to research the correct approach

**During implementation:**

- Use the most appropriate abstraction level from the start
- Follow established patterns unless there's a compelling reason to deviate
- Write tests alongside implementation, not after
- Document complex logic as you write it
- Prefer editor and IDE tools (file edits, search, rename) over ad-hoc scripts for one-off tasks; write bash or Python scripts only for well-defined, repetitive operations that genuinely benefit from automation

**After implementation:**

- Validate changes using project-specific commands (build, test, lint, type-check)
- Check for errors, warnings, and type issues
- Ensure tests pass and coverage is maintained
- Review diffs for clarity and maintainability

## Coding Style

- Always follow the project's established coding style (naming conventions, formatting, etc.).
- Do not use abbreviations outside of loops (e.g., `i`, `j` for loop counter, `k`, `v` for loop over `key` and `value`, etc.).
- Never put multiple statements on a single line (e.g., condition and call statements must be on their own separate lines).

## Security Baseline

These rules apply universally regardless of language or framework:

- **Never log or expose secrets** — credentials, tokens, private keys, and PII must never appear in logs, error messages, or stack traces.
- **Validate all external input at system boundaries** — treat data from users, APIs, files, and environment variables as untrusted; validate type, format, and range before use.
- **Never construct queries or commands from raw input** — use parameterized queries for databases; avoid shell injection by using structured APIs instead of string interpolation in commands.
- **Avoid unsafe execution primitives** — never use `eval`, `exec`, `Function()`, or equivalent dynamic code execution with user-controlled input.
- **Avoid unsafe deserialization** — never deserialize untrusted data with formats that allow arbitrary object instantiation (e.g., `pickle`, `YAML.load` without a safe loader).
- **Keep dependencies reviewed and updated** — audit new dependencies before adding them; prefer well-maintained packages with small, auditable footprints.
- **Never hardcode secrets in source code** — use environment variables or a secrets manager; `.env` files must be gitignored.

## Linter Suppression Policy

Linter suppression comments (`// biome-ignore`, `// eslint-disable`, `# noqa`, etc.) are sometimes necessary but must be used sparingly and responsibly.

- **Always include a justification** on the same line as the suppression. The justification must explain *why* the rule does not apply, not just what the rule is.
- **Never use file-level suppression** (`biome-ignore-all`, `eslint-disable` without a re-enable) in regular source files — refactor instead.
- **File-level suppression is allowed in test files only** when the whole file uses a pattern that would otherwise require per-line suppressions throughout (e.g., extensive use of `any` in a fixture-driven test file). Document the reason at the top of the file.
- **Suppress the narrowest possible scope**: a single line or block, never a surrounding function or module.

## Quality Standards

Prefer solutions that:

- Maintain or improve code quality
- Are readable and follow established project conventions
- Are properly tested and documented
- Consider long-term implications over short-term convenience
