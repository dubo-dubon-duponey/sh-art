#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

testDirExisting() {
  local exitcode
  local path

  # XXX travis
  path="${TMPDIR:-/tmp}" # $(dirname "${BASH_SOURCE[0]}")"

  exitcode=0
  dc::fs::isdir "$path" || exitcode=$?
  dc-tools::assert::equal "Directory $path exists?" NO_ERROR "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::fs::isdir "$path" writable || exitcode=$?
  dc-tools::assert::equal "Directory $path is writable?" NO_ERROR "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::fs::isdir "$path" writable create || exitcode=$?
  dc-tools::assert::equal "Directory $path can be created?" NO_ERROR "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::fs::isdir "$path" "" create || exitcode=$?
  dc-tools::assert::equal "Directory $path can be created? (wether writable or not)" NO_ERROR "$(dc::error::lookup $exitcode)"
}

testDirNoArg() {
  local exitcode
  local path=""

  exitcode=0
  dc::fs::isdir "$path" || exitcode=$?
  dc-tools::assert::equal "Directory $path exists?" ARGUMENT_INVALID "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::fs::isdir "$path" writable || exitcode=$?
  dc-tools::assert::equal "Directory $path is writable?" ARGUMENT_INVALID "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::fs::isdir "$path" writable create || exitcode=$?
  dc-tools::assert::equal "Directory $path can be created?" ARGUMENT_INVALID "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::fs::isdir "$path" "" create || exitcode=$?
  dc-tools::assert::equal "Directory $path can be created? (wether writable or not)" ARGUMENT_INVALID "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::fs::isdir || exitcode=$?
  dc-tools::assert::equal "Directory '' exists?" ARGUMENT_INVALID "$(dc::error::lookup $exitcode)"
}

testDirNonExisting() {
  local exitcode
  local path

  # Setup
  path="${TMPDIR:-/tmp}/foo"
  chmod a+rwx "$path" 2>/dev/null || true
  rm -Rf "$path"

  # Non existing directory
  exitcode=0
  dc::fs::isdir "$path" || exitcode=$?
  dc-tools::assert::equal "Directory $path exists?" FILESYSTEM "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::fs::isdir "$path" writable || exitcode=$?
  dc-tools::assert::equal "Directory $path is writable?" FILESYSTEM "$(dc::error::lookup $exitcode)"

  # Create it
  exitcode=0
  dc::fs::isdir "$path" writable create || exitcode=$?
  dc-tools::assert::equal "Directory $path can be created?" NO_ERROR "$(dc::error::lookup $exitcode)"

  # Create again without the writable flag
  rm -Rf "$path"
  exitcode=0
  dc::fs::isdir "$path" "" create || exitcode=$?
  dc-tools::assert::equal "Directory $path can be created? (wether writable or not)" NO_ERROR "$(dc::error::lookup $exitcode)"

  # Standard test for existing dir now
  exitcode=0
  dc::fs::isdir "$path" || exitcode=$?
  dc-tools::assert::equal "Directory $path exists?" NO_ERROR "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::fs::isdir "$path" writable || exitcode=$?
  dc-tools::assert::equal "Directory $path is writable?" NO_ERROR "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::fs::isdir "$path" writable create || exitcode=$?
  dc-tools::assert::equal "Directory $path can be created?" NO_ERROR "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::fs::isdir "$path" "" create || exitcode=$?
  dc-tools::assert::equal "Directory $path can be created? (wether writable or not)" NO_ERROR "$(dc::error::lookup $exitcode)"

  # Change it to non writable
  chmod a-w "$path"

  exitcode=0
  dc::fs::isdir "$path" || exitcode=$?
  dc-tools::assert::equal "Directory $path exists?" NO_ERROR "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::fs::isdir "$path" writable || exitcode=$?
  dc-tools::assert::equal "Directory $path is writable?" FILESYSTEM "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::fs::isdir "$path" writable create || exitcode=$?
  dc-tools::assert::equal "Directory $path can be created?" FILESYSTEM "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::fs::isdir "$path" "" create || exitcode=$?
  dc-tools::assert::equal "Directory $path can be created? (wether writable or not)" NO_ERROR "$(dc::error::lookup $exitcode)"

  # Change it to non executable
  chmod a-x "$path"

  exitcode=0
  dc::fs::isdir "$path" || exitcode=$?
  dc-tools::assert::equal "Directory $path exists?" NO_ERROR "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::fs::isdir "$path" writable || exitcode=$?
  dc-tools::assert::equal "Directory $path is writable?" FILESYSTEM "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::fs::isdir "$path" writable create || exitcode=$?
  dc-tools::assert::equal "Directory $path can be created?" FILESYSTEM "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::fs::isdir "$path" "" create || exitcode=$?
  dc-tools::assert::equal "Directory $path can be created? (wether writable or not)" NO_ERROR "$(dc::error::lookup $exitcode)"

  # Change it to non readable
  chmod a-r "$path"

  exitcode=0
  dc::fs::isdir "$path" || exitcode=$?
  dc-tools::assert::equal "Directory $path exists?" FILESYSTEM "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::fs::isdir "$path" writable || exitcode=$?
  dc-tools::assert::equal "Directory $path is writable?" FILESYSTEM "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::fs::isdir "$path" writable create || exitcode=$?
  dc-tools::assert::equal "Directory $path can be created?" FILESYSTEM "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::fs::isdir "$path" "" create || exitcode=$?
  dc-tools::assert::equal "Directory $path can be created? (wether writable or not)" FILESYSTEM "$(dc::error::lookup $exitcode)"

  # Change it to just non writable
  chmod a+rx "$path"

  # Try to create inside
  exitcode=0
  dc::fs::isdir "$path/bar" "" create || exitcode=$?
  dc-tools::assert::equal "Directory $path/bar can be created? (wether writable or not)" FILESYSTEM "$(dc::error::lookup $exitcode)"

  # Change back to writable
  chmod a+w "$path"
  touch "$path/bar"

  exitcode=0
  dc::fs::isdir "$path/bar" || exitcode=$?
  dc-tools::assert::equal "Directory $path/bar exists?" FILESYSTEM "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::fs::isdir "$path/bar" writable || exitcode=$?
  dc-tools::assert::equal "Directory $path/bar is writable?" FILESYSTEM "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::fs::isdir "$path/bar" writable create || exitcode=$?
  dc-tools::assert::equal "Directory $path/bar can be created?" FILESYSTEM "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::fs::isdir "$path/bar" "" create || exitcode=$?
  dc-tools::assert::equal "Directory $path/bar can be created? (wether writable or not)" FILESYSTEM "$(dc::error::lookup $exitcode)"
}

testFile() {
  local exitcode

  # Current script is readable
  exitcode=0
  dc::fs::isfile "${BASH_SOURCE[0]}" || exitcode=$?
  dc-tools::assert::equal "Current script exists" NO_ERROR "$(dc::error::lookup $exitcode)"

  # Creating a file
  chmod a+w "${TMPDIR:-/tmp}/foo" 2>/dev/null || true
  rm -Rf "${TMPDIR:-/tmp}/foo"

  exitcode=0
  dc::fs::isfile "${TMPDIR:-/tmp}/foo" writable create || exitcode=$?
  dc-tools::assert::equal "Creatable file" NO_ERROR "$(dc::error::lookup $exitcode)"

  # Created file is writable
  exitcode=0
  dc::fs::isfile "${TMPDIR:-/tmp}/foo" writable || exitcode=$?
  dc-tools::assert::equal "Created file is writable" NO_ERROR "$(dc::error::lookup $exitcode)"

  chmod a+w "${TMPDIR:-/tmp}/foo"
  rm -f "${TMPDIR:-/tmp}/foo"

  exitcode=0
  dc::fs::isfile "${TMPDIR:-/tmp}/foo" 2>/dev/null || exitcode=$?
  dc-tools::assert::equal "Non existent file does not exist" "FILESYSTEM" "$(dc::error::lookup $exitcode)"

  touch "${TMPDIR:-/tmp}/foo"
  chmod a-w "${TMPDIR:-/tmp}/foo"

  exitcode=0
  dc::fs::isfile "${TMPDIR:-/tmp}/foo" writable 2>/dev/null || exitcode=$?
  dc-tools::assert::equal "Non writable file is not writable" "FILESYSTEM" "$(dc::error::lookup $exitcode)"

  # No file
  exitcode=0
  #  dc::fs::isfile || exitcode=$?
  dc::fs::isfile 2>/dev/null || exitcode=$?

  dc-tools::assert::equal "No path argument fails" "ARGUMENT_INVALID" "$(dc::error::lookup $exitcode)"
}
