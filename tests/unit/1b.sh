#!/usr/bin/env bash

testBasicValidationAllFine(){
  local result
  result="$(. source/core/1b-others.sh 2>&1)"

  dc-tools::assert::equal "exit code ok" 0 "$?"
  dc-tools::assert::contains "response was" "$result" ""
}

testBasicValidationNoGrep(){
  local result
  result="$(PATH="" /bin/bash source/core/1b-others.sh 2>&1)"

  dc-tools::assert::equal "exit code failing with no grep" 144 "$?"
  dc-tools::assert::contains "response was" "$result" "You need grep for this to work"
}

testBasicValidationNoDate(){
  local result
  touch grep
  chmod u+x grep
  result="$(PATH="" /bin/bash source/core/1b-others.sh 2>&1)"

  dc-tools::assert::equal "exit code success even with no date" 0 "$?"
  dc-tools::assert::contains "response was" "$result" "No \"date\" binary on your system. Logs will have no timestamp."

  rm grep
}


