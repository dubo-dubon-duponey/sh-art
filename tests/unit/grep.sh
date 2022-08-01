#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

# Testing this meaningfully is not exactly simple.
testBasicValidationAllFine(){
  local result
  local exitcode

  exitcode=0
  result="$(. source/core/0-in-on-grep.sh 2>&1)" || exitcode="$?"

  dc-tools::assert::equal "exit code ok" 0 "$exitcode"
  dc-tools::assert::contains "response was" "$result" ""
}
