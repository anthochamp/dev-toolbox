#!/usr/bin/env sh
set -eux

dart run build_runner build --delete-conflicting-outputs
