#!/usr/bin/env sh
set -eux

if dart pub deps --executables | grep -q import_sorter; then
	dart run import_sorter:main --no-comments
fi

dart format .
