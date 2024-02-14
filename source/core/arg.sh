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
  # Regexp to match the value against
  local regexp="$2"
  # Exit code
  local ex

  # Grep it
  dc::wrapped::grep -q "$regexp" <<< "$value" \
    || {
      # Failed matching - get the exit code
      ex="$?"

      # If exit code is 145, the value does not match the regexp, we should report it
      # shellcheck disable=SC2015
      [ "$ex" != 145 ] || {
        # Set the error detail explaining what is going on
        dc::error::detail::set "$1 (=$value) [$regexp]"
        # Return argument invalid
        return "$ERROR_ARGUMENT_INVALID"
      }

      # Otherwise, return the exit code as-is
      return "$ex"
    }
}
