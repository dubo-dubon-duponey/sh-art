#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

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
      # shellcheck disable=SC2015
      [ "$grepreturn" == 145 ] && {
        dc::error::detail::set "$1 ($value - $regexp)"
        return "$ERROR_ARGUMENT_INVALID"
      } || true
      return "$grepreturn"
    }
}
