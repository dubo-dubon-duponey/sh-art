#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

# shellcheck disable=SC2034
readonly CLI_DESC="script linter based on shellcheck"

dc::commander::initialize
dc::commander::declare::arg 1 ".+" "source" "Source file (or directory) to lint"
dc::commander::boot

dc::require shellcheck 0.5
dc::require hadolint

dc::fs::isfile "$DC_ARG_1" || dc::fs::isdir "$DC_ARG_1"

for i in "$@"; do
  if dc::fs::isdir "$i"; then
    dc-tooling::sc::dircheck "$i"
    continue
  fi

  dc::fs::isfile "$i"

  dc-tooling::sc::filecheck "$i"
done
