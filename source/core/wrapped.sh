#!/usr/bin/env bash
##########################################################################
# Wrapped
# ------
# "Wrapped" binaries, to manage exit code, portability issues and error output in a sensible / uniform way.
# Do NOT call binaries directly if they are wrapped.
##########################################################################

# XXX this will freeze if there is no stdin and only one argument for example
# Also, we do not do any effort to have fine-grained erroring here (everything wonky ends-up with BINARY_UNKNOWN_ERROR)
# Finally, we of course do not try to validate arguments since that would introduce a circular dep
dc::wrapped::grep(){
  local extended="-E"
  local res

  # If gnu grep, use -P for extended
  [ "${_DC_PRIVATE_IS_GNUGREP+x}" ] || {
    _DC_PRIVATE_IS_GNUGREP=""
    # XXX if using named pipes, and if this is the first call, we need to wrap this below to avoid fucking-up the fd
    _="$(dc::internal::wrap grep --version 2>/dev/null | dc::internal::wrap grep -q "gnu")" && _DC_PRIVATE_IS_GNUGREP=1
#    (dc::internal::wrap grep --version 2>/dev/null | dc::internal::wrap grep -q "gnu") && _DC_PRIVATE_IS_GNUGREP=1
    export _DC_PRIVATE_IS_GNUGREP
  }

  [ "$_DC_PRIVATE_IS_GNUGREP" ] && extended="-P"

  # XXX not clear if we can unwrap
  res="$(dc::internal::wrap grep "$extended" "$@" 2>/dev/null)"
  case $? in
    0)
      printf "%s" "$res"
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

dc::wrapped::base64d(){
  dc::require base64 || return

  case "$(uname)" in
    Darwin)
      base64 -D
    ;;
    *)
      base64 -d
    ;;
  esac
}
