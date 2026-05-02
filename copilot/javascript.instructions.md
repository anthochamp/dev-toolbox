---
name: JavaScript Guidelines
description: Rules and conventions for all JavaScript and TypeScript code — naming conventions, formatting rules, and linter patterns
applyTo: "**/*.{js,mjs,cjs,ts,tsx,mts,cts}"
---

# JavaScript Guidelines

## Naming Conventions

### General Principles

Follow the **S-I-D principle** for all names:

- **Short**: Names must not take long to type and remember
- **Intuitive**: Names must read naturally, as close to common speech as possible
- **Descriptive**: Names must reflect what they do/possess in the most efficient way

Additional rules:

- Always use English for all names
- Be consistent with naming conventions throughout the codebase
- Avoid contractions (e.g., use `onItemClick` not `onItmClk`)
- Avoid context duplication (e.g., in `class MenuItem`, use `handleClick()` not `handleMenuItemClick()`)
- Reflect the expected result (e.g., use `isDisabled` when checking if something should be disabled, not `isEnabled` with negation)
- Prefix internal/private files/directories with `_` to indicate their limited scope
- Suffix internal/private types/classes/interfaces/functions with `_` to indicate their limited scope
- When a private class field backs a public getter (to expose a read-only view of a mutable internal value), suffix the private field with `_` to distinguish it from the getter name:

  ```typescript
  class Semaphore {
    private value_: number;  // private backing field
    get value(): number { return this.value_; }  // public getter
  }
  ```

- Suffix custom error classes with `Error` for clarity

### Case Conventions

- Use **PascalCase** for class, interface, type, and enum names
- Use **camelCase** for variable, function, and method names
- Use **UPPER_SNAKE_CASE** for constant values (e.g., `MAX_RETRIES`)

### Variables and Properties

- Use **singular** nouns for single values and **plural** nouns for collections/arrays (e.g., `friend` vs `friends`, `User` class vs `users` array)
- For boolean variables/properties, prefer **past-tense verb form** (e.g., `connected`, `processed`, `enabled`, `disabled`)

### Function and Method Naming

Follow the **A/HC/LC pattern**: `prefix? + action (A) + high context (HC) + low context? (LC)`

**Actions (verbs)**:

- `get`: Access data immediately or perform operations that return data — use for both synchronous and asynchronous operations
- `set`: Assign a value declaratively
- `reset`: Return a variable to its initial value/state
- `remove`: Remove something from a collection that continues to exist
- `delete`: Completely erase something from existence
- `compose`: Create new data from existing data
- `handle`: Handle an action/event (typically callbacks)
- `update`: Modify existing data/state
- `create`: Instantiate or generate a new entity
- `find`: Search for and return data based on criteria

**Context**: The domain the function operates on (e.g., `User`, `Post`, `Message`). Include high context to specify what the function operates on; add low context for additional specificity (e.g., `getUser`, `getUserMessages`, `handleClickOutside`).

**Prefixes for predicates and special cases**:

- `is`: Describes a characteristic or state (returns boolean) — e.g., `isBlue`, `isValid()`
- `has`: Describes possession of a value/state (returns boolean) — e.g., `hasProducts`, `hasPermission()`
- `should`: Reflects a positive conditional statement (returns boolean) — e.g., `shouldUpdate`, `shouldRetry()`
- `can`: Describes capability or permission (returns boolean) — e.g., `canExecute()`, `canDelete()`
- `min`/`max`: Minimum or maximum values/boundaries — e.g., `minPosts`, `maxRetries`
- `prev`/`next`: Previous or next state in transitions — e.g., `prevState`, `nextValue`

### Implementation-Agnostic Naming

Use generic function/method names that do not describe their internal structure:

- ❌ `calculateTotal` (implies calculation logic) → ✅ `getTotal`
- ❌ `fetchUserData` (implies network call) → ✅ `getUserData`

### Naming Examples

```typescript
// ❌ BAD — name doesn't reflect expected result
const isEnabled = itemCount > 3
return <Button disabled={!isEnabled} />

// ✅ GOOD
const isDisabled = itemCount <= 3
return <Button disabled={isDisabled} />
```

## Linter Suppression

The general suppression policy (justify all suppressions, no file-level suppression in source files) is defined in `agent-and-coding.instructions.md`. The following specifies the exact syntax for JavaScript/TypeScript linting tools.

**Biome (inline — single line):**

```typescript
// ✅ CORRECT — narrow suppression with justification
// biome-ignore lint/suspicious/noExplicitAny: dynamic property access required for patch loop
(target as any)[methodName] = source[methodName].bind(source);

// ❌ WRONG — no justification
// biome-ignore lint/suspicious/noExplicitAny
const value: any = result;
```

**Biome (file-level — test files only):**

```typescript
// ✅ CORRECT — file-level in a test file with documented reason
/** biome-ignore-all lint/suspicious/noExplicitAny: fixture data uses any for flexible TOML shape assertions */

// ❌ WRONG — file-level suppression in a regular source file
/** biome-ignore-all lint/suspicious/noExplicitAny: ... */
```

**ESLint (inline):**

```typescript
// ✅ CORRECT — single-line disable with justification on same line
const value = result as any; // eslint-disable-line @typescript-eslint/no-explicit-any -- dynamic reflection pattern
```
