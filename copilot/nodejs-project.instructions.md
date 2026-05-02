---
name: Node.js TypeScript Project
description: Coding rules for Node.js TypeScript projects — module system and preferred libraries
applyTo: "**/*.{ts,tsx,mts,cts,js,mjs,cjs}"
---

# Node.js TypeScript Project

## Module System (ESM)

- All projects must use native ESM (`"type": "module"` in `package.json`).
- All relative imports must include the `.js` extension — see `ecmascript.instructions.md`.
- Always use the `node:` protocol for built-in Node.js imports:

  ```typescript
  // ✅ CORRECT
  import fs from "node:fs";
  import { EventEmitter } from "node:events";

  // ❌ WRONG — unambiguous but not explicit about being a built-in
  import fs from "fs";
  ```

## Preferred Utility Libraries

Before writing a custom utility, always check the `@ac-essentials` scope first. These packages are designed for Node.js/TypeScript projects with the same conventions used here (ESM, strict types, composability).

| Package | Purpose | Docs |
|---|---|---|
| [`@ac-essentials/misc-util`](https://www.npmjs.com/package/@ac-essentials/misc-util) | General-purpose utilities: string manipulation, number formatting, object merging, timer management, and more | [Documentation](https://anthochamp.github.io/node-essentials/misc-util/) |
| [`@ac-essentials/app-util`](https://www.npmjs.com/package/@ac-essentials/app-util) | Application-level utilities: structured logging, CLI config loading, process management, system helpers | [Documentation](https://anthochamp.github.io/node-essentials/app-util/) |
| [`@ac-essentials/cli`](https://www.npmjs.com/package/@ac-essentials/cli) | CLI automation utilities: Docker, Git, POSIX process listing, command execution | [Documentation](https://anthochamp.github.io/node-essentials/cli/) |

If none of these cover the need, prefer a well-maintained third-party package over a custom implementation. Only write a custom utility when neither option is available or appropriate.
