# Research → Ask → Plan Workflow

This is a **mandatory 3-step workflow** for changes that affect shared systems or require careful sequencing. Skipping steps can cause service disruption or rework.

## The 3-Step Process

When asked to create playbooks, update documentation, or make infrastructure changes, **always follow these three steps:**

---

### Research First

**Before proposing any changes, research existing documentation and configuration.**

Check these types of documentation:

- Current state documentation (what exists today)
- Architecture and design documentation (factual structure)
- Design rationale documentation (why architecture is designed this way)
- Service configuration reference
- Network configuration reference
- Operational procedures
- Migration phase documentation

Check these types of configuration:

- Infrastructure-as-Code status documentation
- Inventory structure and grouping
- Group variables and host variables
- Roles and playbooks
- Gathered infrastructure data

**Purpose:** Understand what exists before making changes. Don't duplicate work or contradict existing configurations.

---

### Ask, Don't Assume

**If you encounter details that cannot be deduced from documentation, STOP and ask.**

Examples of things to ask about:

- Physical network connections (which NIC is connected to what?)
- Hardware specifications not documented
- Credentials, API keys, certificates
- Network topology details (switch ports, VLANs)
- ISP-specific configurations
- User preferences for implementation approaches
- Undocumented service dependencies
- Current state of partially-implemented features

**Purpose:** Avoid making incorrect assumptions that could break infrastructure or require rework.

---

### Present Plan Before Action

**Before creating files or making changes, present a concise summary.**

**Format (NO codebox):**

> ## Proposed Changes
>
> ### What I Found
>
> - [Brief summary of relevant existing config/docs]
> - [Current state of related systems]
>
> ### Questions/Unclear Items
>
> - [Question 1 about physical topology/credentials/etc.]
> - [Question 2 about implementation preference]
>
> ### Proposed Changes
>
> 1. **Create/Update:** `path/to/file1.yml`
>    - Reason: [why]
>    - Key changes: [what]
>
> 2. **Create/Update:** `path/to/file2.md`
>    - Reason: [why]
>    - Key changes: [what]
>
> ### Await Approval
>
> Ready to proceed? [Y/N] or any modifications needed?

**Purpose:** Give the user visibility and control before execution. Allow for corrections before time is spent on implementation.

---

## When to Skip This Process

You can skip the 3-step process for:

- Simple read-only operations (checking file contents, searching)
- Clarification questions about existing code
- Explaining concepts or documentation
- Bug fixes with clear scope
- Minor typo corrections
