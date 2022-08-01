#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

testBasicValidationNoBash(){
  local result
  local exitcode=0

  result="$(sh source/core/0-in-on-bash.sh 2>&1)" || exitcode="$?"

  dc-tools::assert::equal "exit code" 144 "$exitcode"

  dc-tools::assert::contains "response contained informative message" "$result" "This only works with bash"
}

testBasicValidationBash(){
  local result
  local exitcode=0

  result="$(bash source/core/0-in-on-bash.sh 2>&1)" || exitcode="$?"

  dc-tools::assert::equal "exit code" 0 "$exitcode"

  dc-tools::assert::null "response was null" "$result"
}

testBasicValidationNoPSNoBash(){
  local result
  local exitcode=0

  # shellcheck disable=SC2123
  result="$(PATH=/nonexistent; /bin/sh source/core/0-in-on-bash.sh 2>&1)" || exitcode="$?"

  dc-tools::assert::equal "exit code" 144 "$exitcode"

#  dc-tools::assert::contains "response contained lacks ps" "$result" "Your system lacks ps"
  dc-tools::assert::contains "response contained informative message" "$result" "This only works with bash (BASH:"
}

testBasicValidationNoPSBash(){
  local result
  local exitcode=0

  # shellcheck disable=SC2123,SC2030
  result="$(PATH=/nonexistent; /bin/bash source/core/0-in-on-bash.sh 2>&1)" || exitcode="$?"

  dc-tools::assert::equal "exit code" 0 "$exitcode"

#  dc-tools::assert::contains "response contained lacks ps" "$result" "Your system lacks ps"
  dc-tools::assert::contains "response contained warning" "$result" "Cannot find bash in your path"
}

testBasicValidationBrokenPSNoBash(){
  local result
  local exitcode=0

  # Test requires a working ps being available
  if command -v ps > /dev/null; then
    echo 'if [ "$*" == "-o ppid,comm" ]; then /bin/ps $*; else exit 1; fi' > "${TMPDIR:-/tmp}/ps"
    chmod u+x "${TMPDIR:-/tmp}/ps"

    # shellcheck disable=SC2030,SC2031
    result="$(PATH="${TMPDIR:-/tmp}:$PATH"; /bin/sh source/core/0-in-on-bash.sh 2>&1)" || exitcode="$?"

    rm "${TMPDIR:-/tmp}/ps"

    dc-tools::assert::equal "exit code" 144 "$exitcode"

    dc-tools::assert::contains "response contained broken ps" "$result" "Your ps does not support -p (busybox?)"
    dc-tools::assert::contains "response was" "$result" "This only works with bash."
  fi
}

testBasicValidationBrokenPSBash(){
  local result
  local exitcode=0

  # Test requires a working ps being available
  if command -v ps > /dev/null; then
    echo 'if [ "$*" == "-o ppid,comm" ]; then /bin/ps $*; else exit 1; fi' > "${TMPDIR:-/tmp}/ps"
    chmod u+x "${TMPDIR:-/tmp}/ps"

    # shellcheck disable=SC2030,SC2031
    result="$(PATH="${TMPDIR:-/tmp}:$PATH"; /bin/bash source/core/0-in-on-bash.sh 2>&1)" || exitcode="$?"

    rm "${TMPDIR:-/tmp}/ps"

    dc-tools::assert::equal "exit code" 0 "$exitcode"
    dc-tools::assert::contains "response contained broken ps" "$result" "Your ps does not support -p (busybox?)"
  fi
}

