#!/usr/bin/env bash

testGnuGrep(){
  local exitcode

  exitcode=0
  if [ "$(uname)" == "Darwin" ]; then
    dc::wrapped::grep || exitcode="$?"
    dc-tools::assert::equal "grep system on macOS is NOT gnu" "" "$_DC_PRIVATE_IS_GNUGREP"
  fi

  exitcode=0
  if [ "$(uname)" == "Linux" ]; then
    dc::wrapped::grep || exitcode="$?"
    dc-tools::assert::equal "grep system on linux is gnu" "1" "$_DC_PRIVATE_IS_GNUGREP"
  fi

  # Internals: reset state
  unset _DC_PRIVATE_IS_GNUGREP

  # A bit tricky, but since grep itself is used to match grep output, this always match, hence will say "yes we have gnu grep"
  grep(){
    return 0
  }

  exitcode=0
  dc::wrapped::grep || exitcode="$?"
  dc-tools::assert::equal "tricky grep is considered gnu" "1" "$_DC_PRIVATE_IS_GNUGREP"

  # Internals: reset state
  unset grep
  unset _DC_PRIVATE_IS_GNUGREP
}

testGrep(){
  local exitcode

  exitcode=0
  dc::wrapped::grep "-q" "^foo" <(printf "foo foo bar foo\n") || exitcode="$?"

  dc-tools::assert::equal "grep start match" "0" "$exitcode"

  return
  exitcode=0
  dc::wrapped::grep "-q" "bar foo$" <(printf "foo foo bar foo") || exitcode="$?"
  dc-tools::assert::equal "grep end match" "0" "$exitcode"

  exitcode=0
  dc::wrapped::grep "-q" "baz" <<<"foo foo bar foo" || exitcode="$?"
  dc-tools::assert::equal "grep not match" "GREP_NO_MATCH" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::wrapped::grep "-bogus" "baz" <(printf "foo foo bar foo") || exitcode="$?"
  dc-tools::assert::equal "grep not match" "BINARY_UNKNOWN_ERROR" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::wrapped::grep || exitcode="$?"
  dc-tools::assert::equal "grep not match" "BINARY_UNKNOWN_ERROR" "$(dc::error::lookup $exitcode)"
}