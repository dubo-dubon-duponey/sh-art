#!/usr/bin/env bash

testBasicValidationNoBash(){
  local result
  local exitcode=0

  result="$(sh source/core/0-in-on-bash.sh 2>&1)" || exitcode="$?"

  dc-tools::assert::equal "exit code" 144 "$exitcode"

  dc-tools::assert::contains "response was" "$result" "This only works with bash"
}

testBasicValidationNoPSNoBash(){
  local result
  local exitcode=0

  # shellcheck disable=SC2123
  result="$(PATH=/nonexistent; /bin/sh source/core/0-in-on-bash.sh 2>&1)" || exitcode="$?"

  dc-tools::assert::equal "exit code" 144 "$exitcode"

#  dc-tools::assert::contains "response contained lacks ps" "$result" "Your system lacks ps"
  dc-tools::assert::contains "response contained no bash" "$result" "This only works with bash (BASH:"
}

testBasicValidationNoPS(){
  local result
  local exitcode=0

  # shellcheck disable=SC2123,SC2030
  result="$(PATH=/nonexistent; /bin/bash source/core/0-in-on-bash.sh 2>&1)" || exitcode="$?"

  dc-tools::assert::equal "exit code" 0 "$exitcode"

#  dc-tools::assert::contains "response contained lacks ps" "$result" "Your system lacks ps"
  dc-tools::assert::contains "response contained lacks ps" "$result" "Cannot find bash in your path"

}

testBasicValidationBrokenPS(){
  local result
  local exitcode=0

  echo 'if [ "$*" == "-o ppid,comm" ]; then /bin/ps $*; else exit 1; fi' > "/tmp/ps"
  chmod u+x "/tmp/ps"

  # shellcheck disable=SC2030,SC2031
  result="$(PATH="/tmp:$PATH"; /bin/bash source/core/0-in-on-bash.sh 2>&1)" || exitcode="$?"

  rm "/tmp/ps"

  if command -v ps > /dev/null; then
    dc-tools::assert::equal "exit code" 0 "$exitcode"
    dc-tools::assert::contains "response contained broken ps" "$result" "Your ps does not support -p (busybox?)"
  fi
}

testBasicValidationBrokenPSNoBash(){
  local result
  local exitcode=0

  echo 'if [ "$*" == "-o ppid,comm" ]; then /bin/ps $*; else exit 1; fi' > "/tmp/ps"
  chmod u+x "/tmp/ps"

  # shellcheck disable=SC2030,SC2031
  result="$(PATH="/tmp:$PATH"; /bin/sh source/core/0-in-on-bash.sh 2>&1)" || exitcode="$?"

  rm "/tmp/ps"

  dc-tools::assert::equal "exit code" 144 "$exitcode"

  dc-tools::assert::contains "response contained broken ps" "$result" "Your ps does not support -p (busybox?)"
  dc-tools::assert::contains "response was" "$result" "This only works with bash."
}

