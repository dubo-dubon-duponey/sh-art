#!/usr/bin/env bash

testFile(){
  local result

  _=$(dc::fs::isfile "${BASH_SOURCE[0]}")
  result="$?"
  dc-tools::assert::equal "Current script exists" 0 "$result"

  _=$(dc::fs::isfile "${BASH_SOURCE[0]}" writable)
  result="$?"
  dc-tools::assert::equal "Current script is writable" 0 "$result"

  chmod a+w "${TMPDIR:-/tmp}/foo"
  rm -f "${TMPDIR:-/tmp}/foo"
  _=$(dc::fs::isfile "${TMPDIR:-/tmp}/foo" writable create)
  result="$?"
  dc-tools::assert::equal "Creatable file" 0 "$result"

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

testDir(){
  local result

  _=$(dc::fs::isdir "$(dirname "${BASH_SOURCE[0]}")")
  result="$?"
  dc-tools::assert::equal "Current dir exists" 0 "$result"

  _=$(dc::fs::isdir "$(dirname "${BASH_SOURCE[0]}")" writable)
  result="$?"
  dc-tools::assert::equal "Current dir is writable" 0 "$result"

  chmod a+w "${TMPDIR:-/tmp}/foo"
  rm -Rf "${TMPDIR:-/tmp}/foo"
  _=$(dc::fs::isdir "${TMPDIR:-/tmp}/foo" writable create)
  result="$?"
  dc-tools::assert::equal "Creatable dir" 0 "$result"

  chmod a+w "${TMPDIR:-/tmp}/foo"
  rm -Rf "${TMPDIR:-/tmp}/foo"
  _=$(dc::fs::isdir "${TMPDIR:-/tmp}/foo" 2>/dev/null)
  result="$?"
  dc-tools::assert::equal "Non existent dir does not exist" "$ERROR_FILESYSTEM" "$result"

  touch "${TMPDIR:-/tmp}/foo"
  chmod a-w "${TMPDIR:-/tmp}/foo"
  _=$(dc::fs::isdir "${TMPDIR:-/tmp}/foo" writable 2>/dev/null)
  result="$?"
  dc-tools::assert::equal "Non writable dir is not writable" "$ERROR_FILESYSTEM" "$result"
}
