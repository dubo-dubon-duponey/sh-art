#!/usr/bin/env bash

testGnuGrep(){
  if dc::require::platform::mac; then
    dc::internal::isgnugrep
    dc-tools::assert::equal "grep system on macOS is NOT gnu" "1" "$?"
  fi

  if dc::require::platform::linux; then
    dc::internal::isgnugrep
    dc-tools::assert::equal "grep system on linux is gnu" "0" "$?"
  fi

  # Internals: reset state
  unset _DC_INTERNAL_NOT_GNUGREP

  # A bit tricky, but since grep itself is used to match grep output, this always match, hence will say "yes we have gnu grep"
  grep(){
    return 0
  }

  dc::internal::isgnugrep
  dc-tools::assert::equal "grep GNU" "0" "$?"

  # Internals: reset state
  unset _DC_INTERNAL_NOT_GNUGREP

  # A bit tricky, but since grep itself is used to match grep output, this always match, hence will say "yes we have gnu grep"
  grep(){
    return 1
  }

  dc::internal::isgnugrep
  dc-tools::assert::equal "grep non-GNU" "1" "$?"

  unset _DC_INTERNAL_NOT_GNUGREP
  unset grep
}

testGrep(){
  dc::internal::grep "-q" "^foo" <(printf "foo foo bar foo\n")
  dc-tools::assert::equal "grep start match" "0" "$?"
  dc::internal::grep "-q" "bar foo$" <(printf "foo foo bar foo")
  dc-tools::assert::equal "grep end match" "0" "$?"

  dc::internal::grep "-q" "baz" <(printf "foo foo bar foo")
  dc-tools::assert::equal "grep not match" "ERROR_GREP_NO_MATCH" "$(dc::error::lookup $?)"

  dc::internal::grep "-bogus" "baz" <(printf "foo foo bar foo")
  dc-tools::assert::equal "grep not match" "ERROR_BINARY_UNKNOWN_ERROR" "$(dc::error::lookup $?)"

  dc::internal::grep
  dc-tools::assert::equal "grep not match" "ERROR_BINARY_UNKNOWN_ERROR" "$(dc::error::lookup $?)"
}
