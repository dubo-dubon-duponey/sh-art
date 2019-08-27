#!/usr/bin/env bash

# Used solely below - as a caching mechanism so not to query grep every time preflight
dc::internal::isgnugrep(){
  if [ ! "${_DC_INTERNAL_NOT_GNUGREP+x}" ]; then
    _DC_INTERNAL_NOT_GNUGREP=1
    grep --version 2>/dev/null | grep -q "gnu" && _DC_INTERNAL_NOT_GNUGREP=0
    export _DC_INTERNAL_NOT_GNUGREP
  fi
  return $_DC_INTERNAL_NOT_GNUGREP
}

# XXX this will freeze if there is no stdin and only one argument for example
# Also, we do not do any effort to have fine-grained erroring here (everything wonky ends-up with BINARY_UNKNOWN_ERROR
# Finally, we of course do not try to validate arguments
dc::internal::grep(){
  local extended="-E"

  # If gnu grep, use -P for extended
  dc::internal::isgnugrep && extended="-P"

  grep "$extended" "$@" 2>/dev/null
  case $? in
    0)
      return 0
    ;;
    1)
      return "$ERROR_GREP_NO_MATCH"
    ;;
    *)
      # dc::error::detail::set "grep"
      return "$ERROR_BINARY_UNKNOWN_ERROR"
    ;;
  esac
}
