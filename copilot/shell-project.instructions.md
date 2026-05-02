---
name: Shell Script Project Guidelines
description: Rules and conventions for all shell script project work — directory structure, submodule conventions, and sh-essentials integration
applyTo: "**/*.{sh,inc.sh}"
---

# Shell Script Project Guidelines

## Project Structure

Use the following layout for any shell script project that contains more than a few scripts:

```
<project>/
├── .shellcheckrc              # ShellCheck configuration (required)
├── .gitmodules                # Submodule declarations
├── lib.inc.sh                 # Project-level library entry point (if applicable)
├── <command>.sh               # Top-level executable scripts
├── commands/                  # Subcommand scripts (one file per subcommand)
├── includes/                  # Project-specific library files
├── third_party/
│   └── sh-essentials/         # Pinned submodule (see below)
└── test/                      # Test scripts
```

- Place all reusable logic in `includes/*.inc.sh`, not in top-level scripts.
- Keep top-level scripts thin: initialize, parse arguments, validate, then delegate.
- Name commands that share a parent script after the parent: `vault.sh` delegates to `commands/vault-context.sh`, which delegates to `commands/vault-context-create.sh`.

## sh-essentials

**When developing a shell project with more than trivial scripting, use [sh-essentials](https://gitlab.0.i.grenadine.io/incubator/sh-essentials) as a Git submodule.**

`sh-essentials` provides a portable POSIX library covering the functionality most shell scripts need but that POSIX sh lacks natively: arrays, string manipulation, interactivity, process execution with proper quoting, filesystem utilities, trap management, and assertions.

### Adding as a Submodule

```sh
git submodule add git@gitlab.0.i.grenadine.io:incubator/sh-essentials.git third_party/sh-essentials
git submodule update --init --recursive
```

Pin to a known-good commit after adding. Do not track `HEAD` directly.

### Initialization

In every script that uses the library:

```sh
#!/usr/bin/env sh
# shellcheck source-path=.
set -eu

rootDir=$(dirname "$(realpath "$0")")

. "$rootDir/third_party/sh-essentials/lib.inc.sh"
essentialsInit "$rootDir/third_party/sh-essentials"
```

For scripts in subdirectories, adjust `rootDir` with `..` segments so it always points to the project root where `third_party/` lives.

### Available Modules

| Module | Functions | Purpose |
| --- | --- | --- |
| `cli/base.inc.sh` | `die` | Fatal error with message to stderr, then exit |
| `cli/log.inc.sh` | `log`, `logDebug`, `logError`, `logNotice` | Structured stderr logging with script name prefix |
| `cli/usage.inc.sh` | `usageDefault`, `usageDefaultYN` | Format default values in usage text |
| `cli/interactivity.inc.sh` | `askString` | Interactive prompt with length validation and echo control |
| `cli/validator.inc.sh` | `paramOrDie`, `nonEmptyOrDie`, `emptyOrDie`, `ENOENTOrDie`, `EEXISTOrDie` | Guard functions for argument and precondition validation |
| `debug/assert.inc.sh` | `assertEq` | Equality assertion for test scripts |
| `lang/array.inc.sh` | `arrayNew`, `arrayPush`, `arrayPop`, `arrayAt`, `arrayFirst`, `arrayLast`, `arrayLength`, `arrayForEach`, `arrayReduce` | Portable array implementation using escaped newline-delimited strings |
| `lang/string.inc.sh` | `stringSplit`, `stringForEach`, `stringEscape`, `stringQuoteSQE`, `stringQuoteDQE` | String splitting, escaping, and quoting helpers |
| `lang/stream.inc.sh` | `escapeForSQE`, `escapeForDQE`, `toLower`, `toUpper`, `replaceAll`, `testBRE`, `matchBRE` | Stream-based string operations (pipe-oriented) |
| `os/env.inc.sh` | `envLoad`, `envExport` | Load `.env` files safely; export variables by name |
| `os/fs.inc.sh` | `fsFindUp`, `fsSecureOverwrite`, `fsRemove` | Filesystem utilities: find upward, atomic write, safe remove |
| `os/path.inc.sh` | `pathGetAllBetween`, `pathShorten` | Path traversal and display helpers |
| `os/process.inc.sh` | `process_exec`, `process_attemptExec`, `process_execStatus` | Execute commands built from quoted strings (pairs with `stringQuoteSQE`) |
| `util/make-tmp.inc.sh` | `makeTmpFile`, `makeTmpDir` | `mktemp` wrappers with consistent naming |
| `util/trap-exit.inc.sh` | `trapExit`, `trapAdd`, `trapGet` | Accumulating trap management (add handlers without overwriting) |
| `util/remove-on-exit.inc.sh` | `removeOnExit` | Register a path for automatic cleanup on exit/signal |
| `date.inc.sh` | `dateFormatIso`, `dateFormatRfc`, `dateCompare`, `dateSubtract_s/m/h/d/M/Y` | Date formatting and arithmetic |

### Key Patterns from sh-essentials

**Logging:**

```sh
logError "File not found: $path"   # → script-name: ERROR: File not found: /path
logNotice "Starting import..."
```

**Argument validation:**

```sh
parseArgv "$@"

# In checkParams():
paramOrDie "$address" --address      # required flag
EEXISTOrDie "$configFile"            # file must exist
ENOENTOrDie "$outputFile"            # file must not exist yet
```

**Portable arrays:**

```sh
items=$(arrayNew)
items=$(arrayPush "$items" "alpha" "beta")
items=$(arrayPush "$items" "gamma")

arrayForEach "$items" processItem    # calls processItem for each element
count=$(arrayLength "$items")        # → 3
first=$(arrayFirst "$items")         # → alpha
```

**Safe dynamic command execution (with proper quoting):**

```sh
# Build a command string with properly shell-quoted arguments
cmd="find $(stringQuoteSQE "$dir") -name $(stringQuoteSQE "$pattern")"
result=$(process_exec "$cmd")
```

**Accumulating traps (safe even when multiple libraries register cleanup):**

```sh
tmpFile=$(makeTmpFile)
removeOnExit "$tmpFile"    # equivalent to: trapExit rm -f "$tmpFile"
```

**Loading `.env` files:**

```sh
envLoad "$HOME/.config/myproject/.env"
# or multiple files:
envLoad "$HOME/.config/myproject/base.env" "$HOME/.config/myproject/local.env"
```

### Do Not Re-Implement What sh-essentials Provides

Before writing custom logic, check whether sh-essentials already covers the need:

| Task | sh-essentials solution |
| --- | --- |
| Fatal error + exit | `die "message"` |
| Required parameter check | `paramOrDie "$val" --flag-name` |
| Temporary file with cleanup | `makeTmpFile` + `removeOnExit` |
| Accumulating trap | `trapExit command arg` |
| Portable array | `arrayNew` / `arrayPush` / `arrayForEach` |
| Quoted dynamic execution | `stringQuoteSQE` + `process_exec` |
| Load `.env` file | `envLoad "$file"` |
| Case-fold a string | `toLower` / `toUpper` (pipe-based) |
| Escape for single-quote embedding | `stringQuoteSQE "$value"` |

## ShellCheck Configuration

When using `sh-essentials`, your `.shellcheckrc` must include `external-sources=true` so ShellCheck can resolve the sourced library files:

```ini
external-sources=true
```

You may additionally disable rules that conflict with valid patterns from sh-essentials:

```ini
external-sources=true
disable=SC2016   # expressions in single quotes: intentional in quoting helpers
disable=SC3043   # 'local' is not in POSIX sh: acceptable in projects targeting dash
```

Document any disabled rules with a comment explaining why.
