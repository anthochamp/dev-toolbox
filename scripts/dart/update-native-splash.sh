#!/usr/bin/env sh
set -eux

if dart pub deps --executables | grep -q flutter_native_splash; then
  dart run flutter_native_splash:create
fi
