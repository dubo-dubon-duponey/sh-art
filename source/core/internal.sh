#!/usr/bin/env bash
##########################################################################
# Internal methods
# ------
# A couple of helpers to be used solely internally by the lib
# You should never rely on any of these
##########################################################################

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
# Also, we do not do any effort to have fine-grained erroring here (everything wonky ends-up with BINARY_UNKNOWN_ERROR)
# Finally, we of course do not try to validate arguments since that would introduce a circular dep
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
      return "$ERROR_BINARY_UNKNOWN_ERROR"
    ;;
  esac
}
