#!/usr/bin/env sh
set -eux

if command -v fvm >/dev/null 2>&1; then
	dart() { fvm dart "$@"; }
else
	dart() { command dart "$@"; }
fi

dart run build_runner watch --delete-conflicting-outputs
