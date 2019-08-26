#!/usr/bin/env bash

. source/lib/xt-fs.sh

xtestFile(){
  local result

  # Current script is readable
  _=$(dc::fs::isfile "${BASH_SOURCE[0]}")
  result="$?"
  dc-tools::assert::equal "Current script exists" 0 "$result"

  # Creating a file
  chmod a+w "${TMPDIR:-/tmp}/foo"
  rm -f "${TMPDIR:-/tmp}/foo"
  _=$(dc::fs::isfile "${TMPDIR:-/tmp}/foo" writable create)
  result="$?"
  dc-tools::assert::equal "Creatable file" 0 "$result"

  # Created file is writable
  _=$(dc::fs::isfile "${TMPDIR:-/tmp}/foo" writable)
  result="$?"
  dc-tools::assert::equal "Created file is writable" 0 "$result"

  chmod a+w "${TMPDIR:-/tmp}/foo"
  rm -f "${TMPDIR:-/tmp}/foo"
  _=$(dc::fs::isfile "${TMPDIR:-/tmp}/foo" 2>/dev/null)
  result="$?"
  dc-tools::assert::equal "Non existent file does not exist" "$ERROR_FILESYSTEM" "$result"

  touch "${TMPDIR:-/tmp}/foo"
  chmod a-w "${TMPDIR:-/tmp}/foo"
  _=$(dc::fs::isfile "${TMPDIR:-/tmp}/foo" writable 2>/dev/null)
  result="$?"
  dc-tools::assert::equal "Non writable file is not writable" "$ERROR_FILESYSTEM" "$result"
}
