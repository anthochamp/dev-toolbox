---
name: Node.js TypeScript Scaffolding
description: Project setup rules for Node.js TypeScript projects — tsconfig, vitest, and package.json conventions
applyTo: "**/{package.json,tsconfig*.json,vitest.config.*}"
---

# Node.js TypeScript Scaffolding

## TypeScript Configuration

Every package must have two tsconfig files:

- **`tsconfig.json`** — used by editors and `tsc --noEmit`; includes test files, fixtures, and type stubs.
- **`tsconfig.build.json`** — extends `tsconfig.json` and excludes all non-production files.

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

Use a shared `tsconfig` base package for strict compiler options; individual packages only set `rootDir`, `outDir`, and project-specific overrides. Do not duplicate compiler options across packages.

## Vitest Configuration

The **root** `vitest.config.mjs` uses `defineConfig` with a `projects` array:

```javascript
import { defineConfig } from "vitest/config";
export default defineConfig({
  test: { projects: ["packages/*"] },
});
```

Each **package** with tests must have its own `vitest.config.ts` using `defineProject`:

```typescript
import { defineProject } from "vitest/config";
export default defineProject({
  test: {
    // package-specific overrides only
  },
});
```

Enable `typecheck` in packages with `.test-d.ts` files — they are excluded from `tsconfig.build.json`:

```typescript
export default defineProject({
  test: { typecheck: { enabled: true } },
});
```

## Package.json Conventions

- Always declare `"type": "module"` at the top level.
- `exports` must point to compiled `.js` output, not source `.ts` files.
- `files` must whitelist only `dist/` — never ship `src/` to npm.
- Declare `engines` to make the required Node.js version machine-checkable.

```json
{
  "type": "module",
  "exports": {
    ".": {
      "import": "./dist/index.js",
      "types": "./dist/index.d.ts"
    }
  },
  "files": ["dist"],
  "engines": { "node": ">=22.0.0" }
}
```
