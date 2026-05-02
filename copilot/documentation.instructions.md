---
name: Documentation Guidelines
description: Rules and conventions for all documentation work — project standards, mandatory artifacts, Markdown formatting, and cross-references to language-specific guides
applyTo: "**"
---

# Documentation Guidelines

## Mandatory Project Artifacts

Every project must include the following at the root:

- `README.md` — Project overview, purpose, prerequisites, and quick-start instructions
- `LICENSE` — Open-source license or proprietary notice
- `CHANGELOG.md` — Required for versioned or published projects; follow [Keep a Changelog](https://keepachangelog.com/)

## No Version History in Files

Git commits are the single source of truth for change history. Documentation and configuration files must NOT contain:

- "Last updated: DATE" metadata
- "Changed from X to Y on DATE" entries
- Inline changelogs or revision histories

## Code Documentation

- Use comments sparingly to explain "why" rather than "what"
- Document public APIs and complex logic thoroughly
- Document from a user's perspective — how to use the code, not its implementation details

**Language-specific conventions:**

- JavaScript / TypeScript: JSDoc / TSDoc (see `ecmascript.instructions.md`)
- Ansible plugins and modules: sphinx (reST) formatted docstrings (see `ansible-role.instructions.md`)

## Markdown Formatting

The following rules apply to all `.md` files in the project.

### Structure

- Use ATX headings (`#`, `##`, `###`) — never Setext-style (`===` or `---` underlines)
- One blank line before and after headings, code blocks, and lists
- One blank line between paragraphs; never use double blank lines
- End files with a single trailing newline

### Lists

- Use `-` for unordered lists (not `*` or `+`)
- Use `1.` for all ordered list items (not manually incrementing numbers); the renderer handles numbering
- Indent nested lists with two spaces

### Code Blocks

- Always use fenced code blocks (triple backtick) with a language identifier
- Use `text` for plain output or content with no applicable language

### Links

- Prefer reference-style links for repeated URLs
- Use descriptive link text — never "click here" or bare URLs in prose
- Use relative paths for internal links; absolute URLs for external references

### Prose

- Use `**bold**` for key terms on first introduction or critical warnings
- Use `_italic_` for emphasis, technical terms, and titles
- Use backticks for inline code, file names, commands, and option names

## Structured Documentation (`docs/`)

Documentation in a `docs/` directory follows the **Diátaxis framework**, which organizes content into four distinct types — tutorials, how-to guides, reference, and explanation — each with a specific purpose and audience.

See `diataxis-framework.instructions.md` for detailed writing guidelines, style conventions, and cross-referencing rules per document type.
