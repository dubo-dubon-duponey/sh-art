#!/usr/bin/env bash

testBasicValidationNoBash(){
  local result

  result="$(sh source/core/1a-bash.sh 2>&1)" && {
    dc-tools::assert::equal "should never succeed" true false
  } || {
    dc-tools::assert::equal "exit code" 144 "$?"
  }

  dc-tools::assert::contains "response was" "$result" "This only works with bash."
}

testBasicValidationNoPSNoBash(){
  local result
  result="$(PATH=/nonexistent; /bin/sh source/core/1a-bash.sh 2>&1)" && {
    dc-tools::assert::equal "should never succeed" true false
  } || {
    dc-tools::assert::equal "exit code" 144 "$?"
  }

  dc-tools::assert::contains "response contained lacks ps" "$result" "Your system lacks ps"
  dc-tools::assert::contains "response contained no bash" "$result" "This only works with bash (BASH: /bin/sh"
}

testBasicValidationNoPS(){
  local result

  result="$(PATH=/nonexistent; /bin/bash source/core/1a-bash.sh 2>&1)" || {
    dc-tools::assert::equal "should not fail" true false
  }

  dc-tools::assert::contains "response contained lacks ps" "$result" "Your system lacks ps"
  dc-tools::assert::contains "response contained lacks ps" "$result" "Cannot find bash in your path"

}

testBasicValidationBrokenPS(){
  local result
  echo 'if [ "$*" == "-o ppid,comm" ]; then /bin/ps $*; else exit 1; fi' > ps
  chmod u+x ps

  result="$(PATH="$(pwd):$PATH"; /bin/bash source/core/1a-bash.sh 2>&1)" || {
    dc-tools::assert::equal "should not fail" true false
  }

  dc-tools::assert::contains "response contained broken ps" "$result" "Your ps does not support -p (busybox?)"

  rm ps
}

testBasicValidationBrokenPSNoBash(){
  local result
  echo 'if [ "$*" == "-o ppid,comm" ]; then /bin/ps $*; else exit 1; fi' > ps
  chmod u+x ps

  result="$(PATH="$(pwd):$PATH"; /bin/sh source/core/1a-bash.sh 2>&1)" && {
    dc-tools::assert::equal "should never succeed" true false
  } || {
    dc-tools::assert::equal "exit code" 144 "$?"
  }

  dc-tools::assert::contains "response contained broken ps" "$result" "Your ps does not support -p (busybox?)"
  dc-tools::assert::contains "response was" "$result" "This only works with bash."

  rm ps
}

