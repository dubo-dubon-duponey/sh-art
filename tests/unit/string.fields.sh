#!/usr/bin/env bash

#### Fields
haystack=" 1 2 3 "
dc::string::fields haystack
dc-tools::assert::equal "${result[0]}" 1 "$haystack to be split in array with first value 1"
dc-tools::assert::equal "${result[1]}" 2 "$haystack to be split in array with first value 2"
dc-tools::assert::equal "${result[2]}" 3 "$haystack to be split in array with first value 3"
dc-tools::assert::equal "${#result[@]}" 3 "$haystack to be split in array with length 3"

haystack="   1   2   3   "
dc::string::fields haystack
dc-tools::assert::equal "${result[0]}" 1 "$haystack to be split in array with first value 1"
dc-tools::assert::equal "${result[1]}" 2 "$haystack to be split in array with first value 2"
dc-tools::assert::equal "${result[2]}" 3 "$haystack to be split in array with first value 3"
dc-tools::assert::equal "${#result[@]}" 3 "$haystack to be split in array with length 3"

haystack='   1
 2
  3   '
dc::string::fields haystack
dc-tools::assert::equal "${result[0]}" 1 "$haystack to be split in array with first value 1"
dc-tools::assert::equal "${result[1]}" 2 "$haystack to be split in array with first value 2"
dc-tools::assert::equal "${result[2]}" 3 "$haystack to be split in array with first value 3"
dc-tools::assert::equal "${#result[@]}" 3 "$haystack to be split in array with length 3"

haystack=""
dc::string::fields haystack
dc-tools::assert::equal "${#result[@]}" 0 "$haystack to be split in array with length 0"

haystack='
   '
dc::string::fields haystack
dc-tools::assert::equal "${#result[@]}" 0 "$haystack to be split in array with length 0"

haystack=$'\n'foo$'\n'$'\n'
dc::string::fields haystack
dc-tools::assert::equal "${result[0]}" "foo" "$haystack to be split in array with first value foo"
dc-tools::assert::equal "${#result[@]}" 1 "$haystack to be split in array with length 0"
