#!/usr/bin/env sh
set -eux

if command -v fvm >/dev/null 2>&1; then
	dart() { fvm dart "$@"; }
else
	dart() { command dart "$@"; }
fi

if dart pub deps --executables | grep -q import_sorter; then
	dart run import_sorter:main --no-comments
fi

dart format .
