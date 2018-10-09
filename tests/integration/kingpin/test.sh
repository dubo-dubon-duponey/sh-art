#!/usr/bin/env bash

testKingpin(){
  [ "$(uname)" == Darwin ] || startSkipping

  dc-kingpin -s "BOGUS"
  exit=$?
  dc-tools::assert::equal "$exit" "$ERROR_ARGUMENT_INVALID"

  dc-kingpin -s "go"
  exit=$?
  dc-tools::assert::equal "$exit" "0"

  dc-kingpin -s "node"
  exit=$?
  dc-tools::assert::equal "$exit" "0"

  dc-kingpin -s "python"
  exit=$?
  dc-tools::assert::equal "$exit" "0"

  [ "$(uname)" == Darwin ] || stopSkipping
}
