#!/usr/bin/env bash

testLogger() {
  local result
  local exitcode

  exitcode=0
  result="$(dc::logger::warning "This is warning" 2>/dev/null)" || exitcode="$?"
  dc-tools::assert::equal "Logger info works" NO_ERROR "$(dc::error::lookup "$exitcode")"
  dc-tools::assert::equal "Logger info does not output anything on stdout" "" "$result"

  result="$(dc::logger::warning "This is warning" 2>&1)" || exitcode="$?"
  dc-tools::assert::equal "Logger info works" NO_ERROR "$(dc::error::lookup "$exitcode")"
  dc-tools::assert::contains "Logger info output on stderr" "$result" "This is warning"
}

testLoggerLevelBogus() {
  local result
  local exitcode

  exitcode=0
  dc::logger::level::set || exitcode="$?"
  dc-tools::assert::equal "Set without arg" ARGUMENT_INVALID "$(dc::error::lookup "$exitcode")"

  exitcode=0
  dc::logger::level::set -1 || exitcode="$?"
  dc-tools::assert::equal "Logger info works" ARGUMENT_INVALID "$(dc::error::lookup "$exitcode")"

  exitcode=0
  dc::logger::level::set 0 || exitcode="$?"
  dc-tools::assert::equal "Logger info works" ARGUMENT_INVALID "$(dc::error::lookup "$exitcode")"

  exitcode=0
  dc::logger::level::set 10 || exitcode="$?"
  dc-tools::assert::equal "Logger info works" ARGUMENT_INVALID "$(dc::error::lookup "$exitcode")"

  exitcode=0
  dc::logger::level::set 1.1 || exitcode="$?"
  dc-tools::assert::equal "Logger info works" ARGUMENT_INVALID "$(dc::error::lookup "$exitcode")"
}

testLoggerLevelFilter() {
  local result
  local exitcode

  exitcode=0
  dc::logger::level::set 1 || exitcode="$?"
  dc-tools::assert::equal "Set 1" NO_ERROR "$(dc::error::lookup "$exitcode")"

  result="$(dc::logger::warning "This is warning" 2>&1)" || exitcode="$?"
  dc-tools::assert::equal "Logger info works" NO_ERROR "$(dc::error::lookup "$exitcode")"
  dc-tools::assert::equal "Logger info output on stderr" "" "$result"
}
