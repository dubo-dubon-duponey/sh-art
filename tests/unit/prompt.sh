#!/usr/bin/env bash

testPrompt(){
  local variable
  local exitcode

  exitcode=0
  dc::prompt::input variable "message" silent not-an-integer || exitcode=$?
  dc-tools::assert::equal "dc::prompt::input wrong timeout" "ARGUMENT_INVALID" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::prompt::input "" "message" silent 10 || exitcode=$?
  dc-tools::assert::equal "dc::prompt::input wrong var name" "ARGUMENT_INVALID" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::prompt::input "∞" "message" silent 10 || exitcode=$?
  dc-tools::assert::equal "dc::prompt::input wrong var name" "ARGUMENT_INVALID" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::prompt::input variable "message" silent 1 2>/dev/null || exitcode=$?
  dc-tools::assert::equal "dc::prompt::input timeouting" "ARGUMENT_TIMEOUT" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::prompt::input variable "message" silent 60 2>/dev/null < <(printf "something\n") || exitcode=$?
  dc-tools::assert::equal "dc::prompt::input exit" 0 "$exitcode"
  dc-tools::assert::equal "dc::prompt::input result" "something" "$variable"
}
