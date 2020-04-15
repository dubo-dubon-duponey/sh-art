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
  local exitcode=0

  # If gnu grep, use -P for extended
  if ! [ "${_DC_PRIVATE_IS_GNUGREP+x}" ]; then
    _DC_PRIVATE_IS_GNUGREP=""
    # XXX this will fuck up the file descriptor with bash 5.0.16...
#    dc::internal::securewrap grep -q "gnu" <(dc::internal::securewrap grep --version 2>/dev/null) && _DC_PRIVATE_IS_GNUGREP=1 || true
    # shellcheck disable=SC2015
    _=$(dc::internal::securewrap grep -q "gnu" <(dc::internal::securewrap grep --version 2>/dev/null)) && _DC_PRIVATE_IS_GNUGREP=1 || true
    export _DC_PRIVATE_IS_GNUGREP
  fi

  [ "$_DC_PRIVATE_IS_GNUGREP" ] && extended="-P"

  # Guess if we need to pass stdin along or not
  local args=("$extended")
  args+=("$@")

  local last
  local prev=""
  last="${!#}"
  if [ "$#" -gt 1 ] && [ "${last:0:1}" != "-" ]; then
    prev=$(($# - 1))
    prev="${!prev}"
  fi
  if [ "$#" == 1 ] || [ "${prev:0:1}" == "-" ]; then
    args+=("/dev/stdin")
  fi

  # XXX bash 5.0.16 will fuck up the fd with a while / for loop as well
#  while [ "$#" -gt 0 ]; do
#    arg="$1"
#    if [ "${arg:0:1}" != "-" ]; then
#      count="$#"
#      break
#    fi
#    shift
#    args+=("$arg")
#  done
#  args+=("$@")
#  if [ "$count" == 1 ]; then
#    args+=("/dev/stdin")
#  fi

  dc::internal::securewrap grep "${args[@]}" 2>/dev/null || exitcode=$?
  case "$exitcode" in
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

dc::wrapped::base64d(){
  dc::require base64 || return

  case "$(uname)" in
    Darwin)
      dc::internal::securewrap base64 -D
    ;;
    *)
      dc::internal::securewrap base64 -d
    ;;
  esac
}
