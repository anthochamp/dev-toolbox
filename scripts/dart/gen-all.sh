#!/usr/bin/env sh
set -eux

if grep -q 'generate: true' pubspec.yaml; then
  flutter gen-l10n
fi

if dart pub deps --executables | grep -q build_runner; then
  dart run build_runner build --delete-conflicting-outputs
fi
