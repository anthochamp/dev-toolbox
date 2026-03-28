#!/usr/bin/env sh
set -eux

if grep -q 'sdk: flutter' pubspec.yaml 2>/dev/null; then
	runtime=flutter
else
	runtime=dart
fi

if ls -A test >/dev/null 2>&1; then
	"$runtime" test
fi
