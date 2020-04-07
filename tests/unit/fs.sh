#!/usr/bin/env bash

testDir(){
  local exitcode

  exitcode=0
  dc::fs::isdir "$(dirname "${BASH_SOURCE[0]}")" || exitcode=$?
  dc-tools::assert::equal "Current dir exists" 0 "$exitcode"

  chmod a+w "${TMPDIR:-/tmp}/foo" 2>/dev/null || true
  rm -Rf "${TMPDIR:-/tmp}/foo"

  exitcode=0
  dc::fs::isdir "${TMPDIR:-/tmp}/foo" writable create || exitcode=$?
  dc-tools::assert::equal "Creatable dir" 0 "$exitcode"

  exitcode=0
  dc::fs::isdir "${TMPDIR:-/tmp}/foo" writable || exitcode=$?
  dc-tools::assert::equal "Current dir is writable" 0 "$exitcode"

  chmod a+w "${TMPDIR:-/tmp}/foo"
  rm -Rf "${TMPDIR:-/tmp}/foo"

  exitcode=0
  dc::fs::isdir "${TMPDIR:-/tmp}/foo" 2>/dev/null || exitcode=$?
  dc-tools::assert::equal "Non existent dir does not exist" "$ERROR_FILESYSTEM" "$exitcode"

  touch "${TMPDIR:-/tmp}/foo"
  chmod a-w "${TMPDIR:-/tmp}/foo"

  exitcode=0
  dc::fs::isdir "${TMPDIR:-/tmp}/foo" writable 2>/dev/null || exitcode=$?
  dc-tools::assert::equal "Non writable dir is not writable" "$ERROR_FILESYSTEM" "$exitcode"
}

testFile(){
  local exitcode

  # Current script is readable
  exitcode=0
  dc::fs::isfile "${BASH_SOURCE[0]}" || exitcode=$?
  dc-tools::assert::equal "Current script exists" 0 "$exitcode"

  # Creating a file
  chmod a+w "${TMPDIR:-/tmp}/foo" 2>/dev/null || true
  rm -f "${TMPDIR:-/tmp}/foo"

  exitcode=0
  dc::fs::isfile "${TMPDIR:-/tmp}/foo" writable create  || exitcode=$?
  dc-tools::assert::equal "Creatable file" 0 "$exitcode"

  # Created file is writable
  exitcode=0
  dc::fs::isfile "${TMPDIR:-/tmp}/foo" writable || exitcode=$?
  dc-tools::assert::equal "Created file is writable" 0 "$exitcode"

  chmod a+w "${TMPDIR:-/tmp}/foo"
  rm -f "${TMPDIR:-/tmp}/foo"

  exitcode=0
  dc::fs::isfile "${TMPDIR:-/tmp}/foo" 2>/dev/null || exitcode=$?
  dc-tools::assert::equal "Non existent file does not exist" "$ERROR_FILESYSTEM" "$exitcode"

  touch "${TMPDIR:-/tmp}/foo"
  chmod a-w "${TMPDIR:-/tmp}/foo"

  exitcode=0
  dc::fs::isfile "${TMPDIR:-/tmp}/foo" writable 2>/dev/null || exitcode=$?
  dc-tools::assert::equal "Non writable file is not writable" "$ERROR_FILESYSTEM" "$exitcode"

  # No file
  exitcode=0
  dc::fs::isfile 2>/dev/null || exitcode=$?
  dc-tools::assert::equal "Non writable file is not writable" "$ERROR_ARGUMENT_INVALID" "$exitcode"
}
