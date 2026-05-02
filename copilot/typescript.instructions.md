---
name: TypeScript Guidelines
description: Rules and conventions for all TypeScript code — type system design, strict typing, generics, type guards, and type-level patterns
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
- Use `zod` for runtime schema validation at API/library boundaries only (external input: user configs, API requests, env vars). Do not use Zod for internal functions where static TypeScript types suffice. Use `z.infer<typeof schema>` as the derived TypeScript type. Convert Zod errors to domain-specific error classes. Zod has runtime overhead — avoid where runtime safety is not critical.

  ```typescript
  // ✅ CORRECT — validate at boundary; internal logic uses inferred type
  const UserConfigSchema = z.object({ name: z.string().min(1) });
  export function processUserConfig(raw: unknown): Result {
    return processConfigInternal(UserConfigSchema.parse(raw));
  }

  // ❌ WRONG — unnecessary Zod for an internal parameter
  function internalHelper(data: unknown): void {
    SomeSchema.parse(data); // overkill if caller is trusted
  }
  ```

- Always use explicit `import type { ... }` syntax for type-only imports. This is required with `verbatimModuleSyntax` / `isolatedModules` and improves build performance by preventing type imports from appearing in emitted JavaScript.

  ```typescript
  // ✅ CORRECT
  import type { User } from './user.js';
  import { getUser } from './user.js';
  ```

- Use `as const` for literal types when appropriate.
- Use `readonly` properties and arrays to enforce immutability.
- Prefer plain string union types (`type Foo = 'a' | 'b'`) when key and value are identical. Use `enum` only when key and value are semantically distinct (e.g., `enum HttpStatus { NOT_FOUND = 404 }`); enum keys use `UPPER_SNAKE_CASE`. Never use the const-object-plus-type pattern when keys and values are identical.
- Use `never` type for exhaustive checks in switch statements and conditional types.
- Use `Partial`, `Required`, `Pick`, `Omit`, and other utility types for type transformations. Make extensive use of the `type-fest` library for advanced type utilities.
- Use `unique symbol` as a brand property to create nominally distinct phantom types — prevents accidental mixing of structurally identical shapes:

  ```typescript
  class UserId { static readonly TAG: unique symbol = Symbol('UserId'); readonly [UserId.TAG]: void; }
  class OrderId { static readonly TAG: unique symbol = Symbol('OrderId'); readonly [OrderId.TAG]: void; }
  ```

- Do NOT use `@ts-ignore` or `@ts-expect-error` unless testing private/protected class members; prefer fixing the underlying type issues. When testing types, use the `vitest` `ExpectTypeOf` utilities instead (see <https://vitest.dev/api/expect-typeof.html>).
- Avoid non-null assertions (`!`); prefer proper null/undefined checks. In test files, non-null assertions may be used when previous checks guarantee non-null values.
- Avoid type assertions (`as Type`) unless absolutely necessary; prefer proper typing and type guards. When a direct assertion is rejected by TypeScript due to insufficient type overlap, use the double-cast `as unknown as T` pattern — but always add a comment explaining why the cast is valid. Neither form is runtime-safe; they both suppress the type checker. The double-cast signals a more deliberate escape hatch.

  ```typescript
  // Safe: both T and U extend the same base Record structure at runtime
  return deepMerge(target, source) as unknown as R;
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

## No OOP Mimicry in Functional Code

Do not add factory or builder functions that merely wrap a type — let callers write the object literal directly and rely on TypeScript for correctness. Only introduce a function when it performs real work: parsing, validation, normalization, transformation, or resource allocation.

## Naming Conventions

Naming conventions (S-I-D principle, case rules, function naming, boolean prefixes) are defined in `javascript.instructions.md` and apply to both JavaScript and TypeScript.
