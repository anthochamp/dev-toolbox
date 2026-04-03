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
	flutter clean
	flutter pub get
else
	rm -rf build .dart_tool
	dart pub get
fi
