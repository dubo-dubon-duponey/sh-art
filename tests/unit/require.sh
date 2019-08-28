#!/usr/bin/env bash

testRequire(){
  local version

  dc::require bogus
  dc-tools::assert::equal "dc::require bogus" ERROR_REQUIREMENT_MISSING "$(dc::error::lookup $?)"

  dc::require grep --version 100.1
  dc-tools::assert::equal "dc::require grep 100.1" ERROR_REQUIREMENT_MISSING "$(dc::error::lookup $?)"

  dc::require grep --version 1.0
  dc-tools::assert::equal "dc::require grep 1.0" 0 "$?"

  version="$(grep --version | grep -E "[0-9]+([.][0-9]+)+" | sed -E 's/^[^0-9.]*([0-9]+[.][0-9]+).*/\1/')"
  local major="${version%%.*}"
  local minor="${version#*.}"
  minor=$(( minor - 1 ))
  dc::require grep --version "$major.$minor"
  dc-tools::assert::equal "dc::require grep 2.4" 0 "$?"

  version="$(grep --version | grep -E "[0-9]+([.][0-9]+)+" | sed -E 's/^[^0-9.]*([0-9]+[.][0-9]+).*/\1/')"
  local major="${version%%.*}"
  local minor="${version#*.}"
  dc::require grep --version "$major.$minor"
  dc-tools::assert::equal "dc::require grep 2.5" 0 "$?"

  version="$(grep --version | grep -E "[0-9]+([.][0-9]+)+" | sed -E 's/^[^0-9.]*([0-9]+[.][0-9]+).*/\1/')"
  local major="${version%%.*}"
  local minor="${version#*.}"
  minor=$(( minor + 1 ))
  dc::require grep --version "$major.$minor"
  dc-tools::assert::equal "dc::require grep $major.$minor" ERROR_REQUIREMENT_MISSING "$(dc::error::lookup $?)"
}
