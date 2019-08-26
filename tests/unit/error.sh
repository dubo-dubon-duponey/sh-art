#!/usr/bin/env bash

testError(){
  local res

  dc::error::register ERROR_SOMETHING
  dc-tools::assert::equal "register return" "0" "$?"
  dc-tools::assert::notnull "$ERROR_SOMETHING"
  dc-tools::assert::notnull "$(ENV | grep ERROR_SOMETHING)"

  res="$(dc::error::lookup "$ERROR_SOMETHING")"
  dc-tools::assert::equal "lookup return" "0" "$?"
  dc-tools::assert::equal "ERROR_SOMETHING HAS A CODE" "ERROR_SOMETHING" "$res"

  dc::error::detail::set "foobar"
  dc-tools::assert::equal "set return" "0" "$?"

  res="$(dc::error::detail::get)"
  dc-tools::assert::equal "get return" "0" "$?"
  dc-tools::assert::equal "get what was set" "foobar" "$res"
}
