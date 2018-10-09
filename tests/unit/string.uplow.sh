#!/usr/bin/env bash

testStringUpLow(){
  source="∞Foo"
  result=$(dc::string::toUpper source)
  dc-tools::assert::equal "$source to upper" "$result" "∞FOO"
  result=$(dc::string::toLower source)
  dc-tools::assert::equal "$source to lower" "$result" "∞foo"

  source=""
  result=$(dc::string::toUpper source)
  dc-tools::assert::equal "$source to upper" "$result" ""
  result=$(dc::string::toLower source)
  dc-tools::assert::equal "$source to lower" "$result" ""

  source="∞Foo"$'\n'"bar"
  result=$(printf "%s" "$source" | dc::string::toUpper)
  dc-tools::assert::equal "$source to upper" "$result" "∞FOO"$'\n'"BAR"
  result=$(printf "%s" "$source" | dc::string::toLower)
  dc-tools::assert::equal "$source to lower" "$result" "∞foo"$'\n'"bar"
}

