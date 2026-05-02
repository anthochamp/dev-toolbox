---
name: Diátaxis Documentation Framework
description: Rules and conventions for all documentation work using the Diátaxis framework — tutorials, how-to guides, reference, and explanation writing styles
applyTo: "**/docs/**/*.md"
---

# Diátaxis Documentation Framework

This project follows **[Diátaxis](https://diataxis.fr/)**, a documentation framework that organizes content by purpose.

## Four Document Types

| Type | Purpose | Audience | Content |
| --- | --- | --- | --- |
| **Tutorials** | Learning-oriented | Newcomers | Step-by-step lessons, safe to explore |
| **How-To Guides** | Task-oriented | Practitioners | Goal-focused procedures |
| **Reference** | Information-oriented | Lookup | Accurate technical specifications |
| **Explanation** | Understanding-oriented | Curious minds | Concepts, design decisions, context |

## Tutorials (Learning-Oriented)

**Purpose:** Help newcomers learn by doing in a safe environment.

**Characteristics:**

- Second person ("you"), conversational tone
- "Let's explore...", "Try this...", "Notice how..."
- Complete working examples that build confidence
- Expected outcome clearly stated
- Safe environment where mistakes are okay
- Build knowledge incrementally

**Example topics:**

- "Getting Started with [Technology]"
- "Your First [Service] Deployment"
- "Understanding [Concept] Through Practice"

## How-To Guides (Task-Oriented)

**Purpose:** Help practitioners accomplish specific tasks.

**Characteristics:**

- Imperative mood ("Check status", "Run command")
- Assume basic knowledge exists
- Focus on the goal, not teaching fundamentals
- Minimal explanation (link to explanation docs if needed)
- Troubleshooting section for common issues
- Task-specific, not comprehensive

**Example topics:**

- "How to Bootstrap a New Site"
- "How to Troubleshoot DNS Issues"
- "How to Rotate Secrets"

## Reference (Information-Oriented)

**Purpose:** Provide accurate technical information for lookup.

**Characteristics:**

- Third person, factual, dry tone
- Present tense ("The service runs on port 53")
- Tables, lists, specifications
- Complete and accurate
- No opinions or rationale
- Structured consistently
- Machine-readable when possible

**Example topics:**

- "Service Configuration Reference"
- "API Documentation"
- "Network Topology Specifications"

## Explanation (Understanding-Oriented)

**Purpose:** Help readers understand concepts and design decisions.

**Characteristics:**

- Discuss alternatives and tradeoffs
- "We chose X over Y because..."
- Historical context acceptable here (not in reference)
- Connect concepts across the system
- Help reader understand "why"
- Theoretical knowledge, not procedures

**Example topics:**

- "Why We Use BGP Instead of Static Routing"
- "Architecture Decisions and Tradeoffs"
- "DNS Design Rationale"

## Critical Rules

### DO NOT Mix Document Types

Each document has **ONE purpose**:

❌ **Wrong:**

- Tutorial with embedded reference tables → Split them
- Reference with design rationale → Split explanation out
- How-to with "why we do it this way" → Move to explanation
- Explanation with configuration details → Move to reference

✅ **Correct:**

- Tutorial that links to reference for details
- Reference that links to explanation for context
- How-to that links to both reference and explanation

### Cross-References Between Document Types

**Encouraged link patterns:**

- Reference → Explanation: "For design rationale, see [explanation/...]"
- How-To → Reference: "See [reference/...] for configuration details"
- Tutorial → Reference: "For complete API, see [reference/...]"
- Explanation → Reference: "For technical specs, see [reference/...]"

**Links should flow naturally** - readers dive deeper into explanations from reference, practitioners find config details from how-to guides, learners discover advanced topics from tutorials.

## Writing Style by Type

### Tutorials

- **Tone:** Friendly, encouraging, patient
- **POV:** Second person ("you")
- **Tense:** Present/imperative ("Now you create...", "Let's deploy...")
- **Length:** As long as needed for learning
- **Examples:** Complete, working, safe to experiment

### How-To Guides

- **Tone:** Direct, efficient, practical
- **POV:** Imperative ("Run", "Configure", "Check")
- **Tense:** Imperative mood
- **Length:** As short as possible to accomplish task
- **Examples:** Specific to the task goal

### Reference

- **Tone:** Neutral, factual, precise
- **POV:** Third person
- **Tense:** Present ("The service listens on port...")
- **Length:** Complete coverage of subject
- **Examples:** All options documented

### Explanation

- **Tone:** Thoughtful, contextual, educational
- **POV:** First person plural ("we") when discussing decisions
- **Tense:** Past for decisions ("We chose..."), present for concepts
- **Length:** As long as needed to explain thoroughly
- **Examples:** Illustrative, showing alternatives

## Content Guidelines

### Code/Config Examples

**DO NOT embed in documentation:**

- Full configuration files (>10 lines)
- Complete playbooks or scripts
- Large code blocks

**INSTEAD:**

- Reference file paths: "See `path/to/file.yml`"
- Brief syntax examples (3-5 lines) when necessary for understanding
- Link to example files in dedicated examples directory

**Exception:** Tutorials may include longer examples for educational purposes.

### Version History

**Git commits are the single source of truth for change history.**

Documentation files should NOT contain:

- "Last updated: DATE" (except in top-level README front matter)
- "Changed from X to Y on DATE"
- Change logs or revision histories
- Explanations of why something was updated

### Document Structure

Each document should have:

- **Clear title** that indicates document type and subject
- **Brief introduction** stating purpose and audience
- **Logical structure** appropriate to document type
- **Cross-links** to related documents of different types
- **No mixed purposes** - one type per document
