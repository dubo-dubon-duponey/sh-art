#!/usr/bin/env bash

true
# shellcheck disable=SC2034
readonly CLI_DESC="script linter based on shellcheck"

# Initialize
dc::commander::initialize
dc::commander::declare::arg 1 ".+" "source" "Source file (or directory) to lint"
# Start commander
dc::commander::boot
dc::require shellcheck --version 0.5 || exit
dc::require hadolint || exit

if [ ! -r "$DC_PARGV_1" ]; then
  dc::logger::error "Please provide at least one readable file or directory to lint."
  exit "$ERROR_ARGUMENT_INVALID"
fi

for i in "$@"; do
  if [ ! -r "$i" ]; then
    dc::logger::error "$i is not readable. Ignoring linting on this."
    continue
  fi
  if [ -f "$i" ]; then
    dc-tooling::sc::filecheck "$i"
    if [ "$DC_SHELLCHECK_FAIL" ]; then
      dc::logger::error "Shellcheck failed on file $DC_PARGV_1."
      exit "$ERROR_FAILED"
    fi
    continue
  fi
  dc-tooling::sc::dircheck "$i"
  if [ "$DC_SHELLCHECK_FAIL" ]; then
    dc::logger::error "Shellcheck failed on directory $DC_PARGV_1."
    exit "$ERROR_FAILED"
  fi
done
