---
name: ECMAScript Guidelines
description: Rules and conventions for all JavaScript and TypeScript code — language features, async patterns, module system, and Node.js best practices
applyTo: "**/*.{js,mjs,cjs,ts,tsx,mts,cts}"
---

# ECMAScript Guidelines

## General Best Practices

### Error Handling

- Prefer custom error classes and always handle errors explicitly.

### API Documentation

- Document public APIs with JSDoc/TSDoc comments. Use the following tags consistently:
  - `@returns` — always use `@returns`, never `@return`
  - `@throws {ErrorClass}` — only document when the thrown class is specific and semantically meaningful to callers (i.e., they might realistically catch it to differentiate it from other errors); do not document throws of generic `Error` or unavoidable runtime errors
  - `@internal` — mark items not intended for public use (even if exported for technical reasons)
  - `@deprecated` — mark deprecated APIs with a migration note
  - `@example` — provide usage examples for non-obvious APIs

### Safety

- Avoid unsafe patterns (e.g., `eval`, unsanitized input).

### Module Conventions

- All imports must be at the top of the file.
- In TypeScript projects compiled to ESM, always include the `.js` extension on all relative imports — even when the source file is `.ts`. TypeScript resolves the import, but Node.js requires the `.js` extension at runtime.

  ```typescript
  // ✅ CORRECT
  import { Semaphore } from './async/synchro/semaphore.js';
  ```

- Only use default exports for modules exporting a single entity (e.g., a single class or function) OR if the module is a CJS-only module. Otherwise, always use named exports.

### Code Style

- Use async/await for asynchronous code. Never use `.then()`/`.catch()` unless absolutely necessary (e.g., when handling floating promises, which is rare).
- Only use ternary expressions for simple conditional assignments or returns. For complex conditions, prefer `if`/`else` statements for readability. If the ternary expression is multi-line, consider refactoring to `if`/`else`.
- Only use getter/setter for simple property accessors. For complex logic, prefer explicit methods. **[OOP]**
- Avoid deeply nested code (i.e., more than 3 levels of nesting); prefer early returns and helper functions to flatten structure.
- When working with events, always register listeners before the action that may trigger them.
- Between two equivalent options, prefer the one that improves readability and maintainability.
  Example: prefer `for of` over `Array.prototype.forEach`, even if the latter is more functional. In cases where functional programming improves readability (e.g., chaining `map` and `filter`), prefer it.
- When working with class, organize methods in a logical order (e.g., constructor, public getter/setter, public methods, private methods). **[OOP]**
- Never use IIFE. Use named functions and top-level await instead.

## ECMAScript Features

- Always target the project's specific Node.js version for feature support (check `.nvmrc` or project config). Verify compatibility at [node.green](https://node.green/).
- Prefer modern ES features; avoid polyfilling what the runtime already provides.

### Async & Promises

- Use `for await...of` to consume async iterables (streaming data, paginated APIs).
- Use `Promise.allSettled` when all outcomes matter regardless of rejection; use `Promise.all` only when a single rejection should abort the whole batch.
- Use `Promise.any` to resolve with the first fulfilled promise.
- Use `Promise.prototype.finally` for cleanup that must run regardless of outcome.
- Use `Promise.withResolvers()` to access resolve/reject outside the Promise constructor — avoids the verbose manual `let resolve!` extraction pattern.

### Collections & Objects

- Use `Set` instead of arrays for unique value collections — arrays require explicit runtime deduplication while `Set` enforces uniqueness structurally.
- Use `Map` instead of plain objects for key-value stores with dynamic or non-string keys — plain objects work for static string-keyed records, but `Map` avoids prototype chain collisions and handles any key type cleanly.
- Use `Object.fromEntries` to reconstruct an object from `Object.entries` output or from a `Map`.
- Use `Object.hasOwn(obj, key)` instead of `obj.hasOwnProperty(key)` — safer with null-prototype objects.

### Error Handling

- Use `Error.cause` to preserve original error context when re-throwing:

  ```typescript
  throw new ProcessingError('Step failed', { cause: originalError });
  ```

### Safety & Defaults

- Use optional chaining (`?.`) and nullish coalescing (`??`) for safe property access and null-safe defaults.
- Use logical assignment operators (`&&=`, `||=`, `??=`) for concise conditional mutation.

### Immutable Array Operations

- Prefer `toReversed()`, `toSorted()`, `toSpliced()`, and `with()` over their mutating equivalents (`reverse()`, `sort()`, `splice()`) when the original array must not be modified.

### Cancellation

- Use `AbortController` / `AbortSignal` for cooperative cancellation (fetch, streams, timers, async loops). Pass the signal through the call chain; call `signal.throwIfAborted()` inside long-running loops — it throws `DOMException` with `name === 'AbortError'`.
- Use `AbortSignal.timeout(ms)` for one-shot timeout signals without managing a controller.
- Use `AbortSignal.any([sig1, sig2])` to combine multiple signals (e.g., user cancel + timeout) into one.

### ESNext

- Track stable additions at [node.green](https://node.green/) and TC39. Validate feature support in your target Node.js version before use.
