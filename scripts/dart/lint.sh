#!/usr/bin/env sh
set -eux

if ! dart format --output=none --set-exit-if-changed .; then
	echo Linting failed.
	exit 1
fi

if ! dart analyze --fatal-infos .; then
	echo Linting failed.
	exit 1
fi

if dart pub deps --executables | grep -q ac_code_metrics; then
	if ! dart run ac_code_metrics:metrics analyze .; then
		echo Linting failed.
		exit 1
	fi
fi
