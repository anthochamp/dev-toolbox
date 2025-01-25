#!/usr/bin/env sh
set -eux

dart run build_runner watch --delete-conflicting-outputs
