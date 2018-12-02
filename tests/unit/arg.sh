#!/usr/bin/env bash

testArgGrep() {
  DC_PARGV_1=foobar
  DC_PARGE_1=true
  local result
  result="$(dc::commander::declare::arg 1 "^foo(?:bar)?$" "" "a flag" "a flag")"
  local exit=$?
  dc-tools::assert::equal "$exit" "0"

  result="$(dc::commander::declare::arg 1 "^foo(?:abar)?$" "" "another flag" "another flag")"
  local exit=$?
  dc-tools::assert::equal "$exit" "$ERROR_ARGUMENT_INVALID"
}
