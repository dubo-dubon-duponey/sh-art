#!/usr/bin/env bash

testOutputJSONInvalid(){
  local exitcode=0
  local result

  # Make jq a requirement for these tests
  dc::require jq || return

  result="$(dc::output::json "invalid" 2>/dev/null)" || exitcode="$?"
  dc-tools::assert::equal "exit invalid" "ARGUMENT_INVALID" "$(dc::error::lookup "$exitcode")"
  dc-tools::assert::null "$result"
}

testOutputJSONValid(){
  local exitcode=0
  local result

   # Make jq a requirement for these tests
  dc::require jq || return

  result="$(dc::output::json '"valid"')" || exitcode="$?"
  dc-tools::assert::equal "exit valid" NO_ERROR "$(dc::error::lookup "$exitcode")"
  dc-tools::assert::equal "$result" '"valid"'
}

testOutputJSONInvalidNoJQ(){
  local exitcode=0
  local result

  # This will make it so that calls to jq will fail (because jq can't be find)
  result="$(unset _DC_DEPENDENCIES_B_JQ; PATH="" dc::output::json "invalid")" || exitcode="$?"
  dc-tools::assert::equal "exit invalid" NO_ERROR "$(dc::error::lookup "$exitcode")"
  dc-tools::assert::equal "result empty" 'invalid' "$result"
}

testOutputJSONValidNoJQ(){
  local exitcode=0
  local result

  result="$(unset _DC_DEPENDENCIES_B_JQ; PATH="" dc::output::json '"valid"')" || exitcode="$?"
  dc-tools::assert::equal "exit valid" NO_ERROR "$(dc::error::lookup "$exitcode")"
  dc-tools::assert::equal "$result" '"valid"'
}
