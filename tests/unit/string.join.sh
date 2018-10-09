#!/usr/bin/env bash

testStringJoin(){
  haystack=( 1 2 3 )
  expected="123"
  result=$(dc::string::join haystack)
  dc-tools::assert::equal "${haystack[*]} to be joined into $expected" "$result" "$expected"

  haystack=( 1 2 3 )
  expected="1foo2foo3"
  result=$(dc::string::join haystack "foo")
  dc-tools::assert::equal "${haystack[*]} to be joined into $expected" "$result" "$expected"

  haystack=( 1 2 3 )
  expected="13233"
  result=$(dc::string::join haystack "3")
  dc-tools::assert::equal "${haystack[*]} to be joined into $expected" "$result" "$expected"

  haystack=( 1 2 "" 3 )
  expected="132333"
  result=$(dc::string::join haystack "3")
  dc-tools::assert::equal "${haystack[*]} to be joined into $expected" "$result" "$expected"

  haystack=( 1 2 "" )
  expected="1323"
  result=$(dc::string::join haystack "3")
  dc-tools::assert::equal "${haystack[*]} to be joined into $expected" "$result" "$expected"

  haystack=( "" "" )
  expected="3"
  result=$(dc::string::join haystack "3")
  dc-tools::assert::equal "${haystack[*]} to be joined into $expected" "$result" "$expected"

  haystack=( "" )
  expected=""
  result=$(dc::string::join haystack "3")
  dc-tools::assert::equal "${haystack[*]} to be joined into $expected" "$result" "$expected"

  haystack=()
  expected=""
  result=$(dc::string::join haystack "3")
  dc-tools::assert::equal "${haystack[*]} to be joined into $expected" "$result" "$expected"

  haystack=( "∞" "∞" "∞" )
  expected="∞"$'\n'"∞"$'\n'"∞"
  result=$(dc::string::join haystack $'\n')
  dc-tools::assert::equal "${haystack[*]} to be joined into $expected" "$result" "$expected"
}
