#!/usr/bin/env bash

# Matching
haystack="foo"
needle="foo"
dc::string::contains haystack $needle
dc-tools::assert::equal "$result" true "'$needle' in '$haystack'"
dc::string::index haystack $needle
dc-tools::assert::equal "$result" 0 "'$needle' index in '$haystack'"
dc::string::lastIndex haystack $needle
dc-tools::assert::equal "$result" 0 "'$needle' lastIndex in '$haystack'"
dc::string::count haystack $needle
dc-tools::assert::equal "$result" 1 "'$needle' count in '$haystack'"

haystack="bar foo baz"
needle="foo"
dc::string::contains haystack $needle
dc-tools::assert::equal "$result" true "'$needle' in '$haystack'"
dc::string::index haystack $needle
dc-tools::assert::equal "$result" 4 "'$needle' index in '$haystack'"
dc::string::lastIndex haystack $needle
dc-tools::assert::equal "$result" 4 "'$needle' lastIndex in '$haystack'"
dc::string::count haystack $needle
dc-tools::assert::equal "$result" 1 "'$needle' count in '$haystack'"

haystack='baz
foo
bar
foo'
needle="foo"
dc::string::contains haystack $needle
dc-tools::assert::equal "$result" true "'$needle' in '$haystack'"
dc::string::index haystack $needle
dc-tools::assert::equal "$result" 4 "'$needle' index in '$haystack'"
dc::string::lastIndex haystack $needle
dc-tools::assert::equal "$result" 12 "'$needle' lastIndex in '$haystack'"
dc::string::count haystack $needle
dc-tools::assert::equal "$result" 2 "'$needle' count in '$haystack'"

haystack="foo"
needle="o"
dc::string::contains haystack $needle
dc-tools::assert::equal "$result" true "'$needle' in '$haystack'"
dc::string::index haystack $needle
dc-tools::assert::equal "$result" 1 "'$needle' index in '$haystack'"
dc::string::lastIndex haystack $needle
dc-tools::assert::equal "$result" 2 "'$needle' lastIndex in '$haystack'"
dc::string::count haystack $needle
dc-tools::assert::equal "$result" 2 "'$needle' count in '$haystack'"

haystack="f∞o"
needle="∞"
dc::string::contains haystack $needle
dc-tools::assert::equal "$result" true "'$needle' in '$haystack'"
dc::string::index haystack $needle
dc-tools::assert::equal "$result" 1 "'$needle' index in '$haystack'"
dc::string::lastIndex haystack $needle
dc-tools::assert::equal "$result" 1 "'$needle' lastIndex in '$haystack'"
dc::string::count haystack $needle
dc-tools::assert::equal "$result" 1 "'$needle' count in '$haystack'"

haystack='$a'
needle='$'
dc::string::contains haystack $needle
dc-tools::assert::equal "$result" true "'$needle' in '$haystack'"
dc::string::index haystack $needle
dc-tools::assert::equal "$result" 0 "'$needle' index in '$haystack'"
dc::string::lastIndex haystack $needle
dc-tools::assert::equal "$result" 0 "'$needle' lastIndex in '$haystack'"
dc::string::count haystack $needle
dc-tools::assert::equal "$result" 1 "'$needle' count in '$haystack'"

# Not matching
haystack="foo"
needle="bazar"
dc::string::contains haystack $needle
dc-tools::assert::equal "$result" false "'$needle' in '$haystack'"
dc::string::index haystack $needle
dc-tools::assert::equal "$result" -1 "'$needle' index in '$haystack'"
dc::string::lastIndex haystack $needle
dc-tools::assert::equal "$result" -1 "'$needle' lastIndex in '$haystack'"
dc::string::count haystack $needle
dc-tools::assert::equal "$result" 0 "'$needle' count in '$haystack'"

haystack="foo"
needle=""
dc::string::contains haystack $needle
dc-tools::assert::equal "$result" true "'$needle' in '$haystack'"
dc::string::index haystack $needle
dc-tools::assert::equal "$result" 0 "'$needle' index in '$haystack'"
dc::string::lastIndex haystack $needle
dc-tools::assert::equal "$result" 1 "'$needle' lastIndex in '$haystack'"
dc::string::count haystack $needle
dc-tools::assert::equal "$result" ${#haystack} "'$needle' count in '$haystack'"

haystack=""
needle="baz"
dc::string::contains haystack $needle
dc-tools::assert::equal "$result" false "'$needle' in '$haystack'"
dc::string::index haystack $needle
dc-tools::assert::equal "$result" -1 "'$needle' index in '$haystack'"
dc::string::lastIndex haystack $needle
dc-tools::assert::equal "$result" -1 "'$needle' lastIndex in '$haystack'"
dc::string::count haystack $needle
dc-tools::assert::equal "$result" 0 "'$needle' count in '$haystack'"

haystack=""
needle=""
dc::string::contains haystack $needle
dc-tools::assert::equal "$result" true "'$needle' in '$haystack'"
dc::string::index haystack $needle
dc-tools::assert::equal "$result" 0 "'$needle' index in '$haystack'"
dc::string::lastIndex haystack $needle
dc-tools::assert::equal "$result" 0 "'$needle' lastIndex in '$haystack'"
dc::string::count haystack $needle
dc-tools::assert::equal "$result" 1 "'$needle' count in '$haystack'"
