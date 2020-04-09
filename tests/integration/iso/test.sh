#!/usr/bin/env bash

testMkISO(){
  [ "$(uname)" == Darwin ] || startSkipping

  local iso
  local exitcode

  iso="$(dc::fs::mktemp mkisotest) ∞ fancy" || true
  local vname="fancy ∞ name"

  exitcode=0
  dc-iso -s --name="$vname" --file="$iso" --source="$(pwd)" create || exitcode=$?
  dc-tools::assert::equal "$exitcode" "0"

  exitcode=0
  dc-iso -s --file="$iso" mount || exitcode=$?
  dc-tools::assert::equal "$exitcode" "0"

  exitcode=0
  dc-iso -s --name="$vname" unmount || exitcode=$?
  dc-tools::assert::equal "$exitcode" "0"

  [ "$(uname)" == Darwin ] || endSkipping
}
