#!/usr/bin/env bash
set -u

if [ $# -ne 1 ]; then
	echo "USAGE: ./test.sh TEST_SUITE"
	exit 1
fi

binary="${DBL:-dbl}"
if ! command -v "$binary" > /dev/null; then
	echo "ERROR: dbl executable not found in PATH"
	exit 1
fi

if [ -z "${DBL_LIB:-}" ]; then
	dbl_path=$(command -v "$binary")
	dbl_prefix=$(dirname "$(dirname "$dbl_path")")
	if [ -d "$dbl_prefix/lib/dbl/stdlib" ]; then
		export DBL_LIB="$dbl_prefix/lib/dbl/stdlib"
	else
		echo "ERROR: DBL_LIB is not set and DBL stdlib was not found next to '$dbl_path'"
		exit 1
	fi
fi

flags=""
total_tests=0
passed_tests=0

function simple_test {
	total_tests=$((total_tests + 1))

	local file="$1"
	local cmd=("$binary")
	if [ -n "$flags" ]; then
		# shellcheck disable=SC2206
		cmd+=($flags)
	fi
	cmd+=("$file")

	echo "${cmd[*]}"
	if "${cmd[@]}"; then
		passed_tests=$((passed_tests + 1))
	else
		echo "Test file failed: $file"
	fi
}

function run_with_flags {
	flags="$2"
	$1
}

source "$1"

echo "Passed: ${passed_tests}/${total_tests}"

if [ "$passed_tests" -eq "$total_tests" ]; then
	exit 0
else
	exit 1
fi
