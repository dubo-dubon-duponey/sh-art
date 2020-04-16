#!/usr/bin/env bash
##########################################################################
# Prompt
# ------
# Ask questions
# XXX do not like the parameters order in this API
##########################################################################

dc::prompt::input(){
  local varname="$1"
  local message="${2:-}"
  local silent="${3:-}"
  local timeout="${4:-1000}"
  local args=("-r")

  # Arg validation
  dc::argument::check varname "$DC_TYPE_VARIABLE" || return
  dc::argument::check timeout "$DC_TYPE_UNSIGNED" || return

  # Arg processing
  [ ! "$silent" ]   || args+=("-s")
  [ "$timeout" == 0 ]  || args+=("-t" "$timeout")

  # Prompt and read
  [ ! -t 2 ] || >&2 printf "%s" "$message"
  # shellcheck disable=SC2162
  if ! read "${args[@]}" "${varname?}"; then
    dc::error::detail::set "$timeout"
    return "$ERROR_ARGUMENT_TIMEOUT"
  fi

  # XXX should this really be avoided in silent mode?
  [ ! "$silent" ] || [ ! -t 2 ] || >&2 printf "\n"
}

dc::prompt::question() {
  local message="$1"
  local varname="$2"

  dc::prompt::input "$varname" "$message"
}

dc::prompt::password() {
  local message="$1"
  local varname="$2"

  dc::prompt::input "$varname" "$message" silent
}

dc::prompt::credentials() {
  local message="$1"
  local varname="$2"
  local pmessage="$1"
  local pvarname="$2"

  dc::prompt::question "$message" "$varname"

  # No answer? Stay anonymous
  [ ! "${!varname}" ] && return

  # Otherwise, ask for password
  dc::prompt::password "$pmessage" "$pvarname"
}

dc::prompt::confirm(){
  local message="${1:-}"
  local _

  # Flash it
  >&2 dc::internal::securewrap tput bel 2>/dev/null
  >&2 dc::internal::securewrap tput flash 2>/dev/null

  # Don't care about the return value
  dc::prompt::input _ "$message"
}
