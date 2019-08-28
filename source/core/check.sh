#!/usr/bin/env bash
##########################################################################
# Argument matching
# ------
# This is the method to be used to validate arguments
##########################################################################

# This method obviously does not check its own arguments
dc::argument::check(){
  local value="${!1}"
  local regexp="$2"

  dc::internal::grep -q "$regexp" <<< "$value" \
    || {
      dc::error::detail::set "$1 ($value - $regexp)"
      return "$ERROR_ARGUMENT_INVALID"
    }
}
