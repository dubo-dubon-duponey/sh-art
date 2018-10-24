#!/usr/bin/env bash

readonly CLI_DESC="script linter based on shellcheck"

# Initialize
dc::commander::initialize
dc::commander::declare::arg 1 ".+" "" "source" "Source file (or directory) to lint"
# Start commander
dc::commander::boot
dc::require shellcheck "--version" "0.5"

if [ ! -r "$1" ]; then
  dc::logger::error "Please provide a readable file or directory to lint."
  exit "$ERROR_ARGUMENT_INVALID"
fi


if [ -f "$1" ]; then
  dc-tools::sc::filecheck "$1"
  if [ "$DC_SHELLCHECK_FAIL" ]; then
    dc::logger::error "Shellcheck failed."
    exit "$ERROR_FAILED"
  fi
  exit
fi

dc-tools::sc::dircheck "$1"
# XXX broken
if [ "$DC_SHELLCHECK_FAIL" ]; then
  dc::logger::error "Shellcheck failed."
  exit "$ERROR_FAILED"
fi
