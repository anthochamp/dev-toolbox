---
name: Node.js TypeScript Project Setup
description: Project-level conventions for Node.js TypeScript projects — module system, tsconfig setup, vitest configuration, and monorepo patterns
applyTo: "**"
---

# Node.js TypeScript Project Setup

These guidelines apply to any Node.js project written in TypeScript.

## Module System (ESM)

- All projects must use native ESM (`"type": "module"` in `package.json`).
- All relative imports must include the `.js` extension — see `ecmascript.instructions.md`.
- Always use the `node:` protocol for built-in Node.js imports:

  ```typescript
  // ✅ CORRECT
  import fs from "node:fs";
  import path from "node:path";
  import { EventEmitter } from "node:events";

  // ❌ WRONG — unambiguous but not explicit about being a built-in
  import fs from "fs";
  ```

## TypeScript Configuration

### Development vs Build Split

Every package must have two tsconfig files:

- **`tsconfig.json`** — full configuration used by editors and for type-checking; includes test files, fixture files, and type declaration stubs.
- **`tsconfig.build.json`** — extends `tsconfig.json` and explicitly excludes all non-production files for the compiled output.

```json
// tsconfig.build.json
{
  "extends": "./tsconfig.json",
  "exclude": [
    "**/*.spec*.ts",
    "**/*.test*.ts",
    "**/*.test-d.ts",
    "**/__mocks__/*",
    "**/__fixtures__/*"
  ]
}
```

This ensures the compiled output only contains production code, while editors and `tsc --noEmit` still see the full project including tests.

### Shared Base Configs

Use a shared `tsconfig` package (or equivalent) to define strict base configurations. Individual packages extend it and only set `rootDir`, `outDir`, and project-specific overrides. Do not duplicate compiler options across packages.

## Vitest Configuration

### Monorepo: Root + Per-Package Split

- The **root** `vitest.config.mjs` (or `vitest.config.ts`) uses `defineConfig` with a `projects` array pointing to each package:

  ```javascript
  // vitest.config.mjs (root)
  import { defineConfig } from "vitest/config";
  export default defineConfig({
    test: {
      projects: ["packages/*"],
    },
  });
  ```

- Each **package** that has tests must have its own `vitest.config.ts` using `defineProject`. This allows per-package configuration without repeating global settings:

  ```typescript
  // packages/my-package/vitest.config.ts
  import { defineProject } from "vitest/config";
  export default defineProject({
    test: {
      // package-specific overrides only
    },
  });
  ```

### Type-Level Tests

Enable type checking in packages that contain `.test-d.ts` files:

```typescript
// packages/my-package/vitest.config.ts
import { defineProject } from "vitest/config";
export default defineProject({
  test: {
    typecheck: {
      enabled: true,
    },
  },
});
```

Type-level test files use the `.test-d.ts` suffix and are excluded from the build tsconfig (see above).

## Package.json Conventions

- The `main` / `exports` field must point to compiled `.js` output, not source `.ts` files.
- Always declare `"type": "module"` at the top level.
- Use the `exports` map to precisely control what is importable by consumers:

  ```json
  {
    "type": "module",
    "exports": {
      ".": {
        "import": "./dist/index.js",
        "types": "./dist/index.d.ts"
      }
    }
  }
  ```

- The `files` field must whitelist only the `dist/` output — never ship `src/` to npm.
- Declare the `engines` field to make the required Node.js version explicit and machine-checkable:

  ```json
  {
    "engines": {
      "node": ">=22.0.0"
    }
  }
  ```

## Preferred Utility Libraries

Before writing a custom utility, always check the `@ac-essentials` scope first. These packages are designed for Node.js/TypeScript projects with the same conventions used here (ESM, strict types, composability).

| Package | Purpose | Docs |
|---|---|---|
| [`@ac-essentials/misc-util`](https://www.npmjs.com/package/@ac-essentials/misc-util) | General-purpose utilities: string manipulation, number formatting, object merging, timer management, and more | [Documentation](https://anthochamp.github.io/node-essentials/misc-util/) |
| [`@ac-essentials/app-util`](https://www.npmjs.com/package/@ac-essentials/app-util) | Application-level utilities: structured logging, CLI config loading, process management, system helpers | [Documentation](https://anthochamp.github.io/node-essentials/app-util/) |
| [`@ac-essentials/cli`](https://www.npmjs.com/package/@ac-essentials/cli) | CLI automation utilities: Docker, Git, POSIX process listing, command execution | [Documentation](https://anthochamp.github.io/node-essentials/cli/) |

If none of these cover the need, prefer a well-maintained third-party package over a custom implementation. Only write a custom utility when neither option is available or appropriate.
