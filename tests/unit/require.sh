#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

testRequireBogus() {
  local version
  local exitcode

  exitcode=0
  dc::require || exitcode="$?"
  dc-tools::assert::equal "dc::require" ARGUMENT_INVALID "$(dc::error::lookup "$exitcode")"

  exitcode=0
  dc::require bogus || exitcode="$?"
  dc-tools::assert::equal "dc::require nonexistent" REQUIREMENT_MISSING "$(dc::error::lookup "$exitcode")"

  exitcode=0
  dc::require grep 2.5 --bogusflag || exitcode="$?"
  dc-tools::assert::equal "dc::require grep 2.5 --bogusflag" ARGUMENT_INVALID "$(dc::error::lookup "$exitcode")"
}

testRequire() {
  local version
  local exitcode

  version="$(grep --version | grep -E "[0-9]+([.][0-9]+)+" | sed -E 's/^[^0-9.]*([0-9]+[.][0-9]+).*/\1/')"
  local major="${version%%.*}"
  local minor="${version#*.}"

  exitcode=0
  dc::require grep 100.1 || exitcode="$?"
  dc-tools::assert::equal "dc::require grep 100.1" REQUIREMENT_MISSING "$(dc::error::lookup "$exitcode")"

  exitcode=0
  dc::require grep 1.0 || exitcode="$?"
  dc-tools::assert::equal "dc::require grep 1.0" NO_ERROR "$(dc::error::lookup "$exitcode")"

  exitcode=0
  dc::require grep || exitcode="$?"
  dc-tools::assert::equal "dc::require grep" NO_ERROR "$(dc::error::lookup "$exitcode")"

  exitcode=0
  dc::require grep "$major.$((minor - 1))" || exitcode="$?"
  dc-tools::assert::equal "dc::require grep $major.$((minor - 1))" NO_ERROR "$(dc::error::lookup "$exitcode")"

  exitcode=0
  dc::require grep "$major.$minor" || exitcode="$?"
  dc-tools::assert::equal "dc::require grep $major.$minor" NO_ERROR "$(dc::error::lookup "$exitcode")"

  exitcode=0
  dc::require grep "$major.$((minor + 1))" || exitcode="$?"
  dc-tools::assert::equal "dc::require grep $major.$((minor + 1))" REQUIREMENT_MISSING "$(dc::error::lookup $exitcode)"
}

testRequirePlatform(){
  local platform
  platform="$(uname)"

  exitcode=0
  dc::require::platform "$platform" || exitcode="$?"
  dc-tools::assert::equal "Current platform being required should have always worked..." NO_ERROR "$(dc::error::lookup "$exitcode")"

  exitcode=0
  dc::require::platform "" || exitcode="$?"
  dc-tools::assert::equal "Asking for empty string should fail" ARGUMENT_INVALID "$(dc::error::lookup "$exitcode")"

  exitcode=0
  dc::require::platform || exitcode="$?"
  dc-tools::assert::equal "Asking for nothing should fail" ARGUMENT_INVALID "$(dc::error::lookup "$exitcode")"

  exitcode=0
  dc::require::platform "Whatever" || exitcode="$?"
  dc-tools::assert::equal "Asking for shit should fail" REQUIREMENT_MISSING "$(dc::error::lookup "$exitcode")"
}
