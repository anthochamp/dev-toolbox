#!/usr/bin/env sh
set -eux

if command -v fvm >/dev/null 2>&1; then
	flutter() { fvm flutter "$@"; }
else
	flutter() { command flutter "$@"; }
fi

if ! grep -q 'sdk: flutter' pubspec.yaml 2>/dev/null; then
	echo 'Not a Flutter project, skipping l10n generation.'
	exit 0
fi

flutter gen-l10n
