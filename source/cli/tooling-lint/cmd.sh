#!/usr/bin/env bash

readonly CLI_VERSION="0.0.1"
readonly CLI_LICENSE="MIT License"
readonly CLI_DESC="script linter (part of the dc-tooling suite)"
readonly CLI_USAGE="[-s] file-or-directory"

dc::commander::init

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
