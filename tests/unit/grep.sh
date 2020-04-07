#!/usr/bin/env bash

# Testing this meaningfully is not exactly simple.
xtestBasicValidationAllFine(){
  local result
  local exitcode

  exitcode=0
  result="$(. source/core/0-in-on-grep.sh 2>&1)" || exitcode="$?"

  dc-tools::assert::equal "exit code ok" 0 "$exitcode"
  dc-tools::assert::contains "response was" "$result" ""
}
