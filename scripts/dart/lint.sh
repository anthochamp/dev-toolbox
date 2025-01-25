#!/usr/bin/env sh
set -eux

dart format --output=none --set-exit-if-changed .

dart analyze --fatal-infos .

if dart pub deps --executables | grep -q ac_code_metrics; then
  dart run ac_code_metrics:metrics analyze .
fi
