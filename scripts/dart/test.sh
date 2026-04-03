#!/usr/bin/env sh
set -eux

if command -v fvm >/dev/null 2>&1; then
	dart() { fvm dart "$@"; }
	flutter() { fvm flutter "$@"; }
else
	dart() { command dart "$@"; }
	flutter() { command flutter "$@"; }
fi

if grep -q 'sdk: flutter' pubspec.yaml 2>/dev/null; then
	runtime=flutter
else
	runtime=dart
fi

if ls -A test >/dev/null 2>&1; then
	"$runtime" test
fi
