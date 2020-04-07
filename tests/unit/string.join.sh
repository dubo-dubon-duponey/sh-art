#!/usr/bin/env bash

. source/lib/string.sh

testStringJoin(){
  local exitcode

  haystack=( 1 2 3 )
  expected="123"
  exitcode=0
  result=$(dc::string::join haystack) || exitcode=$?
  dc-tools::assert::equal "${haystack[*]:-} to be joined into $expected" "$expected" "$result"

  haystack=( 1 2 3 )
  expected="1foo2foo3"
  exitcode=0
  result=$(dc::string::join haystack "foo") || exitcode=$?
  dc-tools::assert::equal "${haystack[*]:-} to be joined into $expected" "$expected" "$result"

  haystack=( 1 2 3 )
  expected="13233"
  exitcode=0
  result=$(dc::string::join haystack "3") || exitcode=$?
  dc-tools::assert::equal "${haystack[*]:-} to be joined into $expected" "$expected" "$result"

  haystack=( 1 2 "" 3 )
  expected="132333"
  exitcode=0
  result=$(dc::string::join haystack "3") || exitcode=$?
  dc-tools::assert::equal "${haystack[*]:-} to be joined into $expected" "$expected" "$result"

  haystack=( 1 2 "" )
  expected="1323"
  exitcode=0
  result=$(dc::string::join haystack "3") || exitcode=$?
  dc-tools::assert::equal "${haystack[*]:-} to be joined into $expected" "$expected" "$result"

  haystack=( "" "" )
  expected="3"
  exitcode=0
  result=$(dc::string::join haystack "3") || exitcode=$?
  dc-tools::assert::equal "${haystack[*]:-} to be joined into $expected" "$expected" "$result"

  haystack=( "" )
  expected=""
  exitcode=0
  result=$(dc::string::join haystack "3") || exitcode=$?
  dc-tools::assert::equal "${haystack[*]:-} to be joined into $expected" "$expected" "$result"

  haystack=()
  expected=""
  exitcode=0
  result=$(dc::string::join haystack "3") || exitcode=$?
  dc-tools::assert::equal "${haystack[*]:-} to be joined into $expected" "$expected" "$result"

  haystack=( "∞" "∞" "∞" )
  expected="∞"$'\n'"∞"$'\n'"∞"
  exitcode=0
  result=$(dc::string::join haystack $'\n') || exitcode=$?
  dc-tools::assert::equal "${haystack[*]:-} to be joined into $expected" "$expected" "$result"
}
