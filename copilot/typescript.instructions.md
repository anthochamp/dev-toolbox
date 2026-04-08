---
name: TypeScript Guidelines
description: TypeScript type system, strict typing rules, and type-level patterns
applyTo: "**/*.{ts,tsx,mts,cts}"
---

# TypeScript Guidelines

## General Best Practices

- Use strict mode and strict type checking (TypeScript) for safer code.
- Prefer type inference where possible to reduce verbosity.
- Use `interface` for class interfaces (prefixed with `I`, e.g., `IUserService`) and `type` otherwise (e.g., for data structures, function types, mapped types).
- Avoid using `any`; prefer `unknown` or specific types.
- Use union and intersection types for flexible type definitions.
- Leverage generics for reusable and type-safe components.
- Use the `zod` library for runtime schema validation when necessary, or use type guards and assertion functions for custom validation when `zod` is not available.
- Always use explicit `import type { ... }` syntax for type-only imports. This is required with `verbatimModuleSyntax` / `isolatedModules` and improves build performance by preventing type imports from appearing in emitted JavaScript.

  ```typescript
  // ✅ CORRECT
  import type { User } from './user.js';
  import { getUser } from './user.js';

  // ❌ WRONG
  import { User, getUser } from './user.js';
  ```

- Use `as const` for literal types when appropriate.
- Use `readonly` properties and arrays to enforce immutability.
- Prefer plain string union types (`type Foo = 'a' | 'b'`) over const-object-plus-type patterns.
  - Use a string union type when the values stand alone (key and value are the same — e.g., `'pending' | 'active' | 'closed'`).
  - Use `enum` when the type acts as a **key/value mapping table**: keys and values are semantically distinct (e.g., `enum HttpStatus { NOT_FOUND = 404, OK = 200 }`). Justified precisely when the indirection (name vs. value) carries meaning.
  - Never use the const-object-plus-type pattern (`const Foo = { A: 'a' } as const; type Foo = ...`) when keys and values are identical — a plain string union is always cleaner.
- Use `never` type for exhaustive checks in switch statements and conditional types.
- Use `Partial`, `Required`, `Pick`, `Omit`, and other utility types for type transformations. Make extensive use of the `type-fest` library for advanced type utilities.
- Use `unique symbol` as a brand property to create nominally distinct types from structurally identical shapes (phantom types). This prevents accidental mixing of unrelated values that happen to share the same structure:

  ```typescript
  // Each type has a unique symbol tag — TypeScript rejects passing an OrderId where UserId is expected
  class UserId {
    static readonly TAG: unique symbol = Symbol('UserId');
    readonly [UserId.TAG]: void;
  }
  class OrderId {
    static readonly TAG: unique symbol = Symbol('OrderId');
    readonly [OrderId.TAG]: void;
  }
  ```

- Do NOT use `@ts-ignore` or `@ts-expect-error` unless testing private/protected class members; prefer fixing the underlying type issues. When testing types, use the `vitest` `ExpectTypeOf` utilities instead (see <https://vitest.dev/api/expect-typeof.html>).
- Avoid non-null assertions (`!`); prefer proper null/undefined checks. In test files, non-null assertions may be used when previous checks guarantee non-null values.
- Avoid type assertions (`as Type`) unless absolutely necessary; prefer proper typing and type guards. When a direct assertion is rejected by TypeScript due to insufficient type overlap, use the double-cast `as unknown as T` pattern — but always add a comment explaining why the cast is valid. Neither form is runtime-safe; they both suppress the type checker. The double-cast signals a more deliberate escape hatch.

  ```typescript
  // ✅ CORRECT — document the reason
  // Safe: both T and U extend the same base Record structure at runtime
  return deepMerge(target, source) as unknown as R;

  // ❌ WRONG — undocumented, no justification
  return result as R;
  ```

- Use the following convention for absent values:

  | Location | Type |
  | --- | --- |
  | Function arguments / object properties | `T \| null \| undefined` |
  | Return values | `T \| null` |
  | No-value return | `void` |

  Never use `undefined` as a standalone return type — use `void`. Never use `undefined` alone in arguments or properties — pair it with `null` to allow both explicit `null` and omission.
- When defining custom error types, always extend the appropriate base error class (`Error`, `TypeError`, `RangeError`, etc.) and set the `name` property for debugging. **Create specific error subclasses** whenever an error is semantically distinguishable from others — i.e., when a caller might want to catch that specific error class to differentiate it from unrelated runtime errors. Name properties and constructor arguments to identify the failure context.

  ```typescript
  // ✅ CORRECT — specific error class when callers can differentiate
  export class FileNotFoundError extends Error {
    constructor(public readonly path: string) {
      super(`File not found: ${path}`);
      this.name = 'FileNotFoundError';
    }
  }

  // ❌ WRONG — throwing a generic Error when callers cannot distinguish it
  throw new Error(`File not found: ${path}`);
  ```

- In any case, always refer to the project `tsconfig.json` configuration for specific compiler options and settings.
- In class constructors, prefer using parameter properties to define and initialize class members in a concise way.

## Naming Conventions

Naming conventions (S-I-D principle, case rules, function naming, boolean prefixes) are defined in `javascript.instructions.md` and apply to both JavaScript and TypeScript.
