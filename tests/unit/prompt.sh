#!/usr/bin/env bash

testPrompt(){
  local variable

  dc::prompt::input variable "message" silent not-an-integer
  dc-tools::assert::equal "dc::prompt::input wrong timeout" "ERROR_ARGUMENT_INVALID" "$(dc::error::lookup $?)"


  _="$(dc::prompt::input "" "message" silent 10)"
  dc-tools::assert::equal "dc::prompt::input wrong var name" "ERROR_ARGUMENT_INVALID" "$(dc::error::lookup $?)"

  _="$(dc::prompt::input "∞" "message" silent 10)"
  dc-tools::assert::equal "dc::prompt::input wrong var name" "ERROR_ARGUMENT_INVALID" "$(dc::error::lookup $?)"

  _="$(dc::prompt::input variable "message" silent 1 2>/dev/null)"
  dc-tools::assert::equal "dc::prompt::input timeouting" "ERROR_ARGUMENT_TIMEOUT" "$(dc::error::lookup $?)"

  dc::prompt::input variable "message" silent 60 2>/dev/null < <(printf "something\\n")
  dc-tools::assert::equal "dc::prompt::input exit" 0 "$?"
  dc-tools::assert::equal "dc::prompt::input result" "something" "$variable"
}
