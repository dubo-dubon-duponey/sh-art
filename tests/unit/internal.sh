#!/usr/bin/env bash

testInternalWrap(){
  local exitcode

  exitcode=0
  dc::internal::securewrap ls >/dev/null || exitcode=$?
  dc-tools::assert::equal "normal ls" "0" "$exitcode"

  exitcode=0
  PATH="" dc::internal::securewrap ls >/dev/null || exitcode=$?
  dc-tools::assert::equal "no path ls" "0" "$exitcode"
}

testInternalVarNorm(){
  local exitcode
  local result

  exitcode=0
  result="$(dc::internal::varnorm "foobar-baz")" || exitcode=$?
  dc-tools::assert::equal "varnorm" "0" "$exitcode"
  dc-tools::assert::equal "varnorm" "FOOBAR_BAZ" "$result"

  tr(){
    return 42
  }

  exitcode=0
  result="$(PATH="" dc::internal::varnorm "foobar-baz")" || exitcode=$?
  dc-tools::assert::equal "varnorm" "144" "$exitcode"
  dc-tools::assert::equal "varnorm" "" "$result"

  exitcode=0
  result="$(PATH="" dc::internal::varnorm "foobar_baz")" || exitcode=$?
  dc-tools::assert::equal "varnorm" "0" "$exitcode"
  dc-tools::assert::equal "varnorm" "foobar_baz" "$result"
}
