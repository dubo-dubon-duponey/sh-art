#!/usr/bin/env bash

# Test the tester
testAssert() {
  dc-tools::assert::notequal " " $'\n'
  dc-tools::assert::notequal " " $'\t'
  dc-tools::assert::notequal " " $'\r'
  dc-tools::assert::notequal $'\r' $'\n'

  dc-tools::assert::equal "1=1" 1 1

  dc-tools::assert::notnull "0 is not null" 0
  dc-tools::assert::null "Empty string is null" ""
}
