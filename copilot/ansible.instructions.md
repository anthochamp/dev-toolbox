---
name: Ansible Playbook & Inventory Guidelines
description: Rules and conventions for all Ansible playbook and inventory work — task structure, variable patterns, and coding style
applyTo: "**/*.{yml,yaml,j2}"
---

# Ansible Playbook & Inventory Guidelines

> Source: [Red Hat Community of Practice — Automation Good Practices](https://redhat-cop.github.io/automation-good-practices/)
>
> These are opinionated guidelines based on field experience, called "good practices" rather than "best practices" because they must be adapted to specific use cases, organization needs, and context.

## Automation Structures

Use the right structure for the right purpose:

- **Roles:** Reusable components for specific functionality — see `ansible-role.instructions.md` for authoring roles and collections
- **Playbooks:** Orchestration of roles and tasks
- **Collections:** Package related roles, modules, and plugins together
- Keep structures simple and focused on a single purpose
- Author loosely coupled, hierarchical content

## Playbooks

### Keep Playbooks Simple

- Keep playbooks as simple as possible — playbooks should orchestrate, not implement
- Move complex logic to roles

### Tasks vs Roles

- Use either `tasks` or `roles` in playbooks, **not both**
- Prefer roles for all actual work
- Use the `tasks` section only for simple orchestration

### Tags

- Use tags either for roles or for complete purposes
- Do not over-tag individual tasks
- Keep tag strategy simple and consistent

### Debug Verbosity

- Use the verbosity parameter with debug statements (`verbosity: 2` for detailed output)
- Do not leave debug statements at default verbosity in production

## Inventories and Variables

### Single Source of Truth

- Identify your Single Source(s) of Truth and use it/them in your inventory
- Do not duplicate data across multiple sources

### As-Is vs To-Be

- Use inventory for "As-Is" facts (current state)
- Use variables for "To-Be" desired state

### Structured Directory Inventory

- Define inventory as a structured directory instead of a single file
- Use `group_vars/` and `host_vars/` directories; organize variables hierarchically
- Rely on inventory to loop over hosts — do not create lists of hosts in playbooks or variables

### Variable Types

- Prefer inventory variables for infrastructure facts
- Use `group_vars`/`host_vars` for configuration
- Minimize use of `set_fact` — it pollutes global scope
- Prefer inventory variables over extra vars to describe desired state
- Reserve extra vars for runtime overrides only

## Coding Style

### Naming Things

- Use valid Python identifiers in `snake_case_naming_schemes`; no special characters other than underscore
- Use mnemonic and descriptive names (human-readable); pattern `object[_feature]_action` for sorting
- Avoid numbering playbooks; avoid abbreviations (use capitals for abbreviations where unavoidable)
- **Name all tasks, plays, and blocks** — write task names in imperative mood (e.g., "Ensure service is running")

### YAML and Jinja2 Syntax

- Indent at two spaces; indent list contents beyond the list definition
- Split long expressions into multiple lines
- If a `when:` condition is an `and` expression, break it into a list of conditions
- Use `| bool` filter when using bare variables in `when`
- All playbooks must pass `ansible-playbook --syntax-check`
- Spell out all task arguments in YAML style — **do not use `key=value` arguments**
- Use `true`/`false` for boolean values, not `yes`/`no`
- Use double quotes for YAML strings; Jinja2 strings use single quotes
- Do not quote short module keywords like `present`, `absent`; do quote user-side strings
- Use `.yml` extension, not `.yaml`
- Use JSON syntax only when it adds readability; stick to YAML otherwise
- Use single space inside Jinja2 delimiters: `{{ variable_name | default('value') }}`
- Avoid comments in playbooks — ensure task `name` is descriptive enough instead
- Do not add "Updated on DATE" comments (Git tracks this)
- ansible-lint enforces short line length; wrap long Jinja2 expressions across lines as needed

### Ansible Guidelines

- Ensure all tasks are idempotent; support check mode using `changed_when:` and `check_mode:` when needed
- Prefer dedicated modules over `command` or `shell`; prefer `command` over `shell` unless shell features are required
- When using `command` or `shell`, add a comment justifying the choice; avoid `lineinfile` — prefer `template`
- Use the smallest variable scope possible; prefer block or task variables over `set_fact`
- Role variables are exposed to the whole play via `roles:` or `import_role:` — prefer restricted scope
- Do not override role defaults/vars with `set_fact` — use a different variable name
- Use `float`, `int`, `bool` filters to cast variables for type safety
- Use `| bool` filter for bare variables in `when`; do not use `eq`, `equalto`, or `==` Jinja tests
- Avoid `when: foo_result is changed` — use handlers and handler chains instead
- `import_*` for static inclusion (parse time); `include_*` for dynamic inclusion (run time)
- Beware of `ignore_errors: true` on blocks — it silences all asserts
- Task names can be dynamic using variables at the end of string; never use loop variable `item` in task names
- Use bracket notation: `item['key']` not `item.key` (more reliable with special-character keys)
- Do not use `meta: end_play`
- Avoid calling `package` iteratively — pass the full list: `name: "{{ foo_packages }}"`
- Prefer `yum`/`dnf`/`apt` over the agnostic `package` module when package names differ per OS
- Limit `copy` to remote files, static files, and binary blobs — use `template` for everything else
