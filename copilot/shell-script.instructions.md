---
name: Shell Script Guidelines
description: POSIX shell scripting conventions, portability rules, error handling, and ShellCheck usage
applyTo: "**/*.{sh,inc.sh}"
---

# Shell Script Guidelines

## Shell Selection

- Default to **POSIX sh** (`#!/usr/bin/env sh`) for all executable scripts — widest compatibility.
- Never use bash-specific features unless the script explicitly requires bash and documents why.

## File Naming

- Executable scripts: `<name>.sh`
- Library/include files (sourced, not executed): `<name>.inc.sh`
- Group related commands in separate script files under a `commands/` directory rather than branching inside a single large script.

## Strict Mode

All scripts must begin with:

```sh
#!/usr/bin/env sh
set -eu
```

- `-e` — Exit immediately on any command that returns a non-zero status.
- `-u` — Treat unset variables as errors.

Add `# shellcheck source-path=<dir>` after the shebang when sourcing files relative to a known root, to allow ShellCheck to resolve them:

```sh
#!/usr/bin/env sh
# shellcheck source-path=.
set -eu
```

## ShellCheck

- Every project must have a `.shellcheckrc` at the project root. Minimum recommended content:

  ```ini
  external-sources=true
  ```

- `external-sources=true` allows ShellCheck to follow sourced files found at runtime paths.
- Suppress individual warnings inline only when necessary. Always include a justification:

  ```sh
  # shellcheck disable=SC2068  # word splitting is intentional here for positional args
  "$rootDir/commands/$command.sh" $commandArgs
  ```

- Never use file-level suppression in production scripts.

## Script Skeleton

```sh
#!/usr/bin/env sh
# shellcheck source-path=.
set -eu

rootDir=$(dirname "$(realpath "$0")")

. "$rootDir/third_party/sh-essentials/lib.inc.sh"
essentialsInit "$rootDir/third_party/sh-essentials"

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTION]... <argument>

Options:
  -h, --help    Print this help screen
EOF
}

myOption=default
myArg=

parseArgv() {
  while :; do
    case "${1:-}" in
    -h | --help)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    -*) die "$1": unknown argument ;;
    *) break ;;
    esac
    shift
  done

  myArg=${1:?missing argument}
}

checkParams() {
  # validate dependencies between params here
  :
}

parseArgv "$@"
checkParams

# main logic here
```

## Portability Rules (POSIX, No Bashisms)

Strictly avoid bash-only syntax, since scripts must run under `/bin/sh`:

| ❌ Avoid (bash-only) | ✅ Use instead |
| --- | --- |
| `[[ condition ]]` | `[ condition ]` |
| `local -r var=value` | `local var=value` (dash ignores `-r`) |
| `echo -e "text\n"` | `printf 'text\n'` |
| `` `cmd` `` | `$(cmd)` |
| `source file` | `. file` |
| `read var` | `read -r var` |
| `${var,,}` / `${var^^}` | `printf '%s' "$var" \| tr '[:upper:]' '[:lower:]'` / `tr '[:lower:]' '[:upper:]'` |
| `${var/pattern/repl}` | `printf '%s' "$var" \| sed 's/pattern/repl/'` |
| `(( expr ))` | `$(( expr ))` or `[ "$(( expr ))" -ne 0 ]` |
| `array=(a b c)` | Newline-delimited string or use sh-essentials array API |
| `&>file` | `>file 2>&1` |
| `declare -A map` | Use `case` dispatch or flat variable naming (`map_key=value`) |
| `function foo() {}` | `foo() {}` (POSIX function syntax) |
| `test -v var` | `[ -n "${var+set}" ]` (checks if var is defined, even if empty) |
| `$'\t'` / `$'\n'` | Use a here-doc or `printf` to get literal tab/newline |

### Common Portable Patterns

**String contains:**

```sh
# ✅ POSIX — test if $haystack contains $needle
case "$haystack" in
  *"$needle"*) echo found ;;
esac
```

**String starts/ends with:**

```sh
# starts with
[ "${var#prefix}" != "$var" ] && echo "has prefix"

# ends with
[ "${var%suffix}" != "$var" ] && echo "has suffix"
```

**String length:**

```sh
length=${#var}
```

**String to lower/upper (no bashism):**

```sh
lower=$(printf '%s' "$var" | tr '[:upper:]' '[:lower:]')
upper=$(printf '%s' "$var" | tr '[:lower:]' '[:upper:]')
```

**Strip trailing newline from command substitution** (shell does this automatically — do not use `printf '%s'` wrappers unless preserving exact output into a variable):

```sh
# Shell strips trailing newlines from $() — this is expected
result=$(command_that_adds_newline)
```

**Check if a command exists:**

```sh
if command -v docker >/dev/null 2>&1; then
  echo "docker available"
fi
```

**Default value patterns:**

```sh
# Use default if unset or empty
: "${var:=default}"

# Use value only if var is set (non-empty)
arg=${var:+"--flag=$var"}
```

**Safely pass optional flags to commands:**

```sh
# Build flags without arrays
flags=
[ "$verbose" -eq 1 ] && flags="$flags --verbose"
[ -n "$output" ] && flags="$flags --output=$(stringQuoteSQE "$output")"
# then: eval "command $flags"
# See sh-essentials process_exec for the quoting helper
```

**Arithmetic without (( )):**

```sh
n=$(( n + 1 ))
[ $(( a > b )) -ne 0 ] && echo "a is greater"
```

**Temporary variable trick to test set-ness (not emptiness):**

```sh
# Is $var defined at all (even as empty string)?
[ -n "${var+x}" ] && echo "var is set"
```

## Variables

- Always quote variable expansions: `"$var"`, `"$1"`, `"$(cmd)"`.
- Use `${var:-default}` for safe defaults; `${var:?message}` to fail fast on unset required vars.
- Declare all function-local variables with `local` at the top of the function.
- Use `local result=` (initialized empty) rather than bare `local result` to avoid inheriting a value.
- Assign command substitutions separately from `local` to preserve the exit code:

  ```sh
  # ✅ CORRECT — exit code of realpath is preserved
  local dir
  dir=$(realpath "$1")

  # ❌ WRONG — local always exits 0, so set -e won't catch realpath failure
  local dir=$(realpath "$1")
  ```

- Use lowercase `snake_case` for all variable names; reserve `UPPER_CASE` for environment variables.

## Error Handling

Use a central `die()` function for fatal errors:

```sh
die() {
  if [ "$#" -gt 0 ]; then
    logError "$@"
    exit 1
  fi
  exit 0
}
```

- Call `die` with a message for user-visible errors; the message goes to stderr.
- Validate required arguments early with `paramOrDie` / `nonEmptyOrDie` patterns:

  ```sh
  paramOrDie "$address" --address   # exits with error if $address is empty
  ```

- Validate preconditions (path exists, mutually exclusive flags) in a dedicated `checkParams()` function called after `parseArgv`.

### `set -e` Pitfalls and Workarounds

`set -e` exits on any non-zero exit code, including inside `if` conditions and some subshells. Understand the rules to avoid surprises:

```sh
# ✅ SAFE — set -e does NOT exit when a command is in a condition
if grep -q pattern file; then echo found; fi

# ✅ SAFE — || prevents set -e from exiting
value=$(some_command) || true

# ✅ SAFE — reset status with a known-true command
some_fallible_command || step_status=$?
if [ "${step_status:-0}" -ne 0 ]; then ...; fi

# ❌ DANGEROUS — set -e fires in subshell expressions assigned to local
local result=$(may_fail)  # local masks the exit code — use two-line form
```

- When a command is allowed to fail intentionally, suffix it with `|| true` or capture its status explicitly.
- Never rely on `$?` after a multi-step pipeline — capture intermediate statuses if needed.

## Output

- **stderr** — diagnostic output: logs, errors, progress messages.
- **stdout** — data output only: values consumed by callers or pipes.
- Prefer `printf` over `echo` for reliable, portable output; `echo` behavior varies across shells and platforms:

  ```sh
  # ✅ CORRECT
  printf '%s\n' "$value"
  printf 'Count: %d\n' "$count"

  # ❌ AVOID — echo -e, echo -n are not portable
  echo -e "line1\nline2"
  ```

- Use `>&2` to redirect diagnostic output to stderr explicitly.

## Argument Parsing

- Parse arguments in a dedicated `parseArgv()` function.
- Use the `while :; do case; esac; shift; done` pattern — handles `--` end-of-options correctly:

  ```sh
  parseArgv() {
    while :; do
      case "${1:-}" in
      -o | --output)
        shift
        output="$1"
        ;;
      --flag) flag=1 ;;
      -h | --help)
        usage
        exit 0
        ;;
      --)
        shift
        break
        ;;
      -*) die "$1": unknown argument ;;
      *) break ;;
      esac
      shift
    done
  }
  ```

- Prefer long option names (`--flag`) over short ones (`-f`) for clarity; provide both when the short form is conventional.
- Use `${1:?missing ARGUMENT}` for required positional arguments at the end of `parseArgv`.

## Temporary Files and Cleanup

- Always create temporary files with `mktemp`, never hardcode paths:

  ```sh
  tmpFile=$(mktemp "${TMP:-.}/script.XXXXXXXX")
  ```

- Register cleanup via `trap` immediately after creating the resource — before any command that could fail:

  ```sh
  tmpFile=$(mktemp "${TMP:-.}/script.XXXXXXXX")
  trap 'rm -f "$tmpFile"' EXIT INT HUP TERM
  ```

- When multiple resources need cleanup, chain commands in the trap using semicolons, or call a named `cleanup()` function.
- To accumulate trap handlers without overwriting previous ones, capture the existing trap before adding:

  ```sh
  # See sh-essentials trapAdd / trapExit for a portable accumulating trap helper
  ```

- Never write to `/tmp/fixed-name` — it creates a predictable path exploitable by symlink attacks.

## Sourcing Libraries

- Locate the script root with `realpath` at the start of every script; do not rely on `$PWD`:

  ```sh
  rootDir=$(dirname "$(realpath "$0")")
  ```

- Source library files with `.` (not `source`) for POSIX compatibility:

  ```sh
  . "$rootDir/lib/utils.inc.sh"
  ```

- Only source files relative to `$rootDir` — never rely on `PATH` for library files.

## Functions

- Prefer many small functions with a single responsibility over long monolithic scripts.
- Use `camelCase` for function names.
- Keep the main script body at the bottom; define all functions above.
- Avoid defining functions inside other functions except for local callbacks (e.g., iterator callbacks passed to an array utility).

## Boolean Values

- Represent booleans as integers: `0` = false, `1` = true.
- Test with `[ "$flag" -eq 1 ]`, not `[ "$flag" = "true" ]`.

## Here Documents

- Use `<<EOF` for multi-line strings (usage text, configuration output):

  ```sh
  cat <<EOF
  Usage: $(basename "$0") [OPTIONS]
  EOF
  ```

- Use `<<'EOF'` (single-quoted delimiter) when the content must not expand variables.

## Testing

- Place tests in a `test/` directory alongside source files.
- Write test scripts that source the library under test and use assertion functions:

  ```sh
  #!/usr/bin/env dash
  set -euv

  . ./lib.inc.sh

  result=$(myFunction arg1 arg2)
  assertEq "$result" "expected"
  ```

- Use `set -v` in test scripts to print each executed command, making failures easy to trace.
- Name test files after the module they test: `lang-array.sh` tests `src/lang/array.inc.sh`.
