#!/usr/bin/env sh
set -eux

if command -v fvm >/dev/null 2>&1; then
	dart() { fvm dart "$@"; }
	flutter() { fvm flutter "$@"; }
else
	dart() { command dart "$@"; }
	flutter() { command flutter "$@"; }
fi

if grep -q 'generate: true' pubspec.yaml; then
	flutter gen-l10n
fi

if dart pub deps --executables | grep -q build_runner; then
	dart run build_runner build --delete-conflicting-outputs
fi
