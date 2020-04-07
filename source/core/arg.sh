#!/usr/bin/env bash
##########################################################################
# Argument matching
# ------
# This is the method to be used to validate arguments
##########################################################################

# This method obviously does not check its own arguments
dc::argument::check(){
  # Referenced argument could be non-existent
  local value="${!1:-}"
  local regexp="$2"
  local grepreturn

  dc::wrapped::grep -q "$regexp" <<< "$value" \
    || {
      grepreturn="$?"
      [ "$grepreturn" == 145 ] && {
        dc::error::detail::set "$1 ($value - $regexp)"
        return "$ERROR_ARGUMENT_INVALID"
      }
      return "$grepreturn"
    }
}
