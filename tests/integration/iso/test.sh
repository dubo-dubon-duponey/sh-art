#!/usr/bin/env bash

testMkISO(){
  [ "$(uname)" == Darwin ] || startSkipping

  local iso
  iso="$(portable::mktemp mkisotest) ∞ fancy"
  local vname="fancy ∞ name"

  dc-iso --name="$vname" --file="$iso" --source="$(pwd)" create
  exit=$?
  dc-tools::assert::equal "$exit" "0"

  dc-iso --file="$iso" mount
  exit=$?
  dc-tools::assert::equal "$exit" "0"

  dc-iso --name="$vname" unmount
  exit=$?
  dc-tools::assert::equal "$exit" "0"

  [ "$(uname)" == Darwin ] || stopSkipping
}
