#!/usr/bin/env bash

testMkISO(){
  [ "$(uname)" == Darwin ] || startSkipping

  local iso
  iso="$(dc::portable::mktemp mkisotest) ∞ fancy"
  local vname="fancy ∞ name"

  dc-iso -s --name="$vname" --file="$iso" --source="$(pwd)" create
  exit=$?
  dc-tools::assert::equal "$exit" "0"

  dc-iso -s --file="$iso" mount
  exit=$?
  dc-tools::assert::equal "$exit" "0"

  dc-iso -s --name="$vname" unmount
  exit=$?
  dc-tools::assert::equal "$exit" "0"

  [ "$(uname)" == Darwin ] || endSkipping
}
