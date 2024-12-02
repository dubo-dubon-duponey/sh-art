#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

. source/lib/string.sh

testStringUpLow(){
  local source="∞Foo"
  local result

  source="∞Foo"
  result=$(dc::string::toUpper <(printf "%s" "$source"))
  dc-tools::assert::equal "$source to upper" "$result" "∞FOO"
  result=$(dc::string::toLower <(printf "%s" "$source"))
  dc-tools::assert::equal "$source to lower" "$result" "∞foo"

  source=""
  result=$(dc::string::toUpper <(printf "%s" "$source"))
  dc-tools::assert::equal "$source to upper" "$result" ""
  result=$(dc::string::toLower <(printf "%s" "$source"))
  dc-tools::assert::equal "$source to lower" "$result" ""

  source="∞Foo"$'\n'"bar"
  result=$(printf "%s" "$source" | dc::string::toUpper)
  dc-tools::assert::equal "$source to upper" "$result" "∞FOO"$'\n'"BAR"
  result=$(printf "%s" "$source" | dc::string::toLower)
  dc-tools::assert::equal "$source to lower" "$result" "∞foo"$'\n'"bar"
}

