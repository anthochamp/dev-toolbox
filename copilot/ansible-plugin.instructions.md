---
name: Ansible Plugin Authoring
description: Rules and conventions for all Ansible plugin and module Python code — coding style, argument specs, documentation, and testing
applyTo: "**/*.py"
---

# Ansible Plugin Authoring

## Python Guidelines

- Use PEP8 style guide; add file headers and function comments for intent
- Use Python type hints to document variable types
- Write sphinx (reST) formatted docstrings for all plugin types

## Testing

- Use `pytest` instead of `unittest`
- Write tests for all plugins

## Plugin Structure

- Keep plugin entry files minimal; use clear error/info messages
- Format manually maintained plugin argspecs consistently
- Develop plugins initially using ansible plugin builder
