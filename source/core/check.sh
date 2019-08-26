#!/usr/bin/env bash

# This method obviously does not check its own arguments
dc::argument::check(){
  local value="${!1}"
  local regexp="$2"
#  echo "Gonna test: $value versus $regexp"
  dc::internal::grep -q "$regexp" <<< "$value" \
    || { dc::error::detail::set "$1" && return "$ERROR_ARGUMENT_INVALID"; }
}
