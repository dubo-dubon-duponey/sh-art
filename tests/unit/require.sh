#!/usr/bin/env bash

testRequire(){
  dc::require "bogus"
  dc-tools::assert::equal "require bogus" "ERROR_MISSING_REQUIREMENTS" "$(dc::error::lookup $?)"

  dc::require "grep" "--version" "100.1"
  dc-tools::assert::equal "require grep 100.1" "ERROR_MISSING_REQUIREMENTS" "$(dc::error::lookup $?)"

  dc::require "grep" "--version" "1.0"
  dc-tools::assert::equal "require grep 1.0" "0" "$?"

  dc::require "grep" "--version" "2.4"
  dc-tools::assert::equal "require grep 1.0" "0" "$?"

  dc::require "grep" "--version" "2.5"
  dc-tools::assert::equal "require grep 1.0" "0" "$?"

  dc::require "grep" "--version" "2.6"
  dc-tools::assert::equal "require grep 1.0" "ERROR_MISSING_REQUIREMENTS" "$(dc::error::lookup $?)"
}