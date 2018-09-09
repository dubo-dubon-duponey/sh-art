#!/usr/bin/env bash

readonly CLI_VERSION="0.0.1"
readonly CLI_LICENSE="MIT License"
readonly CLI_DESC="script linter (part of the dc-tooling suite)"
readonly CLI_USAGE="[-s] file-or-directory"

dc::commander::init

if [ -f "$1" ] && [ -r "$1" ]; then
  dc-tools::sc::filecheck "$1"
  if [ "$DC_SHELLCHECK_FAIL" ]; then
    dc::logger::error "Shellcheck failed."
    exit "$ERROR_FAILED"
  fi
  exit
fi

if [ -d "$1" ] && [ -r "$1" ]; then
  dc-tools::sc::dircheck "$1"
  if [ "$DC_SHELLCHECK_FAIL" ]; then
    dc::logger::error "Shellcheck failed."
    exit "$ERROR_FAILED"
  fi
  exit
fi

dc::logger::error "Please provide a valid file or directory to lint."

exit "$ERROR_ARGUMENT_INVALID"
