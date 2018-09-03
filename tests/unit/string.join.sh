#!/usr/bin/env bash

haystack=( 1 2 3 )
result=$(dc::string::join haystack)
dc-tools::assert::equal "$result" "123" "${haystack[@]} to be joined into 123"

haystack=( 1 2 3 )
result=$(dc::string::join haystack "foo")
dc-tools::assert::equal "$result" "1foo2foo3" "${haystack[@]} to be joined into 123"
haystack=( 1 2 3 )
result=$(dc::string::join haystack "3")
dc-tools::assert::equal "$result" "13233" "${haystack[@]} to be joined into 123"
haystack=( 1 2 "" 3 )
result=$(dc::string::join haystack "3")
dc-tools::assert::equal "$result" "132333" "${haystack[@]} to be joined into 123"
haystack=( 1 2 "" )
result=$(dc::string::join haystack "3")
dc-tools::assert::equal "$result" "1323" "${haystack[@]} to be joined into 123"

haystack=( "" "" )
result=$(dc::string::join haystack "3")
dc-tools::assert::equal "$result" "3" "${haystack[@]} to be joined into 123"

haystack=( "" )
result=$(dc::string::join haystack "3")
dc-tools::assert::equal "$result" "" "${haystack[@]} to be joined into 123"

haystack=()
result=$(dc::string::join haystack "3")
dc-tools::assert::equal "$result" "" "${haystack[@]} to be joined into 123"
