#!/usr/bin/env bash

testArgGrep() {
  # shellcheck disable=SC2034
  DC_PARGV_1=foobar
  # shellcheck disable=SC2034
  DC_PARGE_1=true
  local result
  # shellcheck disable=SC2034
  result="$(dc::commander::declare::arg 1 "^foo(?:bar)?$" "" "a flag" "a flag")"
  local exit=$?
  dc-tools::assert::equal "$exit" "0"

  # shellcheck disable=SC2034
  result="$(dc::commander::declare::arg 1 "^foo(?:abar)?$" "" "another flag" "another flag")"
  local exit=$?
  dc-tools::assert::equal "$exit" "$ERROR_ARGUMENT_INVALID"
}
