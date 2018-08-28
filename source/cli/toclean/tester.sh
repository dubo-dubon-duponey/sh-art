#!/usr/bin/env bash

tests::run(){
  pth=${1:-tests}
  local ALL_TESTS=$(ls "$pth")
  local FH=$(cd "$(dirname "${BASH_SOURCE[0]:-$PWD}")" 2>/dev/null 1>&2 && pwd)
  . "$FH/assert.sh"

  for i in $ALL_TESTS; do
    echo "Running test suite: $i"
    . "$pth/$i"
  done
}

tests::run $@
