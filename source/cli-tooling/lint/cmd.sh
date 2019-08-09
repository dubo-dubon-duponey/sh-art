#!/usr/bin/env bash

true
# shellcheck disable=SC2034
readonly CLI_DESC="script linter based on shellcheck"

# Initialize
dc::commander::initialize
dc::commander::declare::arg 1 ".+" "source" "Source file (or directory) to lint"
# Start commander
dc::commander::boot
dc::require shellcheck "--version" "0.5"
dc::require hadolint

if [ ! -r "$DC_PARGV_1" ]; then
  dc::logger::error "Please provide a readable file or directory to lint."
  exit "$ERROR_ARGUMENT_INVALID"
fi

if [ -f "$DC_PARGV_1" ]; then
  dc-tools::sc::filecheck "$DC_PARGV_1"
  if [ "$DC_SHELLCHECK_FAIL" ]; then
    dc::logger::error "Shellcheck failed on file $DC_PARGV_1."
    exit "$ERROR_FAILED"
  fi
  exit
fi

dc-tools::sc::dircheck "$DC_PARGV_1"
if [ "$DC_SHELLCHECK_FAIL" ]; then
  dc::logger::error "Shellcheck failed on directory $DC_PARGV_1."
  exit "$ERROR_FAILED"
fi
