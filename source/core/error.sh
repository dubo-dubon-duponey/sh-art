#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

##########################################################################
# Error management
# ------
# - register to declare new error codes
# - detail:set and get to provide context for errors when they happen
# - lookup to get a readable constant out of an error code
# - throw anytime you need to return non zero
##########################################################################

# IMPORTANT
# This is mind bending: https://stackoverflow.com/questions/44080974/if-errexit-is-on-how-do-i-run-a-command-that-might-fail-and-get-its-exit-code
# And this has nothing to do with -e
# fun(){
#	  throw || return
#	  echo " > should never see me"
#}
#
#notfun(){
#	  throw
#	  echo " > should never see me"
#}
#
# fun || echo $?
#
# notfun || echo $?

readonly _DC_PRIVATE_ERROR_APPMAX=125
_DC_PRIVATE_ERROR_APPCODEPOINT=2
# Maybe turn this into an array?
_DC_PRIVATE_ERROR_DETAIL=

dc::error::detail::set(){
  _DC_PRIVATE_ERROR_DETAIL="$1"
}

dc::error::detail::get(){
  printf "%s" "$_DC_PRIVATE_ERROR_DETAIL"
}

dc::error::lookup(){
  local code="${1:-}"
  local errname=

  dc::argument::check code "$DC_TYPE_UNSIGNED" \
    && [ "$code" -le "255" ] \
    && errname="$(dc::internal::securewrap env 2>/dev/null | dc::wrapped::grep "^ERROR_[^=]+=$code$")" \
    || dc::error::throw ARGUMENT_INVALID || return

  errname="${errname%=*}"
  printf "%s" "${errname#*ERROR_}"
}

dc::error::register(){
  local name="${1:-}"

  dc::argument::check name "$DC_TYPE_VARIABLE" || return

  _DC_PRIVATE_ERROR_APPCODEPOINT=$(( _DC_PRIVATE_ERROR_APPCODEPOINT + 1 ))

  [ $_DC_PRIVATE_ERROR_APPCODEPOINT -le $_DC_PRIVATE_ERROR_APPMAX ] || dc::error::throw LIMIT || return

  read -r "ERROR_${name?}" <<<"$_DC_PRIVATE_ERROR_APPCODEPOINT"
  export "ERROR_${name?}"
  readonly "ERROR_${name?}"
}

dc::error::throw(){
  local name="${1:-}"
  local err_detail="${2:-}"
  local passthrough="${3:-}"

  dc::argument::check name "$DC_TYPE_VARIABLE" || return

  if [ "$passthrough" != "" ]; then
    dc::error::detail::set "$err_detail"
    return "$name"
  fi

  name="ERROR_${name?}"
  # If not set
  [ -z ${!name+x} ] && {
    dc::error::detail::set "$name"
    return "$ERROR_ERROR_UNKNOWN"
  } || {
    dc::error::detail::set "$err_detail"
    return "${!name}"
  }
}
