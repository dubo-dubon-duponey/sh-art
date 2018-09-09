#!/usr/bin/env bash

source="∞Foo"
result=$(dc::string::toUpper source)
dc-tools::assert::equal "$result" "∞FOO" "upper"
result=$(dc::string::toLower source)
dc-tools::assert::equal "$result" "∞foo" "lower"

source=""
result=$(dc::string::toUpper source)
dc-tools::assert::equal "$result" "" "upper"
result=$(dc::string::toLower source)
dc-tools::assert::equal "$result" "" "lower"

source="∞Foo"$'\n'"bar"
result=$(printf "%s" "$source" | dc::string::toUpper)
dc-tools::assert::equal "$result" "∞FOO"$'\n'"BAR" "upper"
result=$(printf "%s" "$source" | dc::string::toLower)
dc-tools::assert::equal "$result" "∞foo"$'\n'"bar" "lower"
