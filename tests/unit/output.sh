#!/usr/bin/env bash

# Make jq a requirement for these tests
dc::require jq

testOutputJSONInvalid(){
  local result
  result="$(dc::output::json "invalid" 2>/dev/null)"
  local exit=$?
  dc-tools::assert::equal "$exit" "$ERROR_ARGUMENT_INVALID"
  dc-tools::assert::null "$result"
}

testOutputJSONValid(){
  local result
  result="$(dc::output::json '"valid"')"
  local exit=$?
  dc-tools::assert::equal "Exit code should be 0" "$exit" "0"
  dc-tools::assert::equal "$result" '"valid"'
}

testOutputJSONInvalidNoJQ(){
  local result
  local previousJQ="$_DC_DEPENDENCIES_B_JQ"
  unset _DC_DEPENDENCIES_B_JQ
  result="$(PATH="" dc::output::json "invalid")"
  local exit=$?
  _DC_DEPENDENCIES_B_JQ="$previousJQ"
  dc-tools::assert::equal "Exit code should be 0" "$exit" "0"
  dc-tools::assert::equal "$result" 'invalid'
}

testOutputJSONValidNoJQ(){
  local result
  _DC_OUTPUT_JSON_JQ=fakejq
  unset _DC_DEPENDENCIES_B_JQ
  result="$(dc::output::json '"valid"')"
  local exit=$?
  export _DC_OUTPUT_JSON_JQ=jq
  dc-tools::assert::equal "Exit code should be 0" "$exit" "0"
  dc-tools::assert::equal "$result" '"valid"'
}
