#!/usr/bin/env bash

# Used solely by dc::internal::grep - as a caching mechanism so not to query grep every time preflight
dc::internal::isgnugrep(){
  if [ ! "${_DC_INTERNAL_NOT_GNUGREP+x}" ]; then
    _DC_INTERNAL_NOT_GNUGREP=1
    grep --version 2>/dev/null | grep -q "gnu" && _DC_INTERNAL_NOT_GNUGREP=0
    export _DC_INTERNAL_NOT_GNUGREP
  fi
  return $_DC_INTERNAL_NOT_GNUGREP
}

dc::internal::grep(){
  dc::require "grep" || return

  local extended="-E"

  # If gnu grep, use -P for extended
  dc::internal::isgnugrep && extended="-P"

  grep "$extended" "$@" 2>/dev/null
  case $? in
    0)
      return
    ;;
    1)
      return "$ERROR_GREP_NO_MATCH"
    ;;
    *)
      dc::error::detail::set "grep"
      return "$ERROR_BINARY_UNKNOWN_ERROR"
    ;;
  esac
}
