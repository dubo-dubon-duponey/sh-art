#!/usr/bin/env bash
##########################################################################
# Error management
# ------
# - register to declare new error codes
# - detail:set and get to provide context for errors when they happen
# - lookup to get a readable constant out of an error code
##########################################################################

_DC_PRIVATE_ERROR_APPCODEPOINT=2
_DC_PRIVATE_ERROR_APPMAX=125
_DC_PRIVATE_ERROR_DETAIL=

dc::error::detail::set(){
  _DC_PRIVATE_ERROR_DETAIL="$1"
}

dc::error::detail::get(){
  printf "%s" "$_DC_PRIVATE_ERROR_DETAIL"
}

dc::error::lookup(){
  local code="${1:-}"
  local errname

  dc::argument::check code "$DC_TYPE_UNSIGNED" \
    && [ "$code" -le "255" ] \
    && errname="$(dc::internal::wrap env 2>/dev/null | dc::wrapped::grep "^ERROR_[^=]+=$code$")" \
    || return "$ERROR_ARGUMENT_INVALID"

  errname="${errname%=*}"
  printf "%s" "${errname#*ERROR_}"
}

dc::error::register(){
  local name="${1:-}"

  dc::argument::check name "$DC_TYPE_VARIABLE" || return

  _DC_PRIVATE_ERROR_APPCODEPOINT=$(( _DC_PRIVATE_ERROR_APPCODEPOINT + 1 ))

  [ $_DC_PRIVATE_ERROR_APPCODEPOINT -le $_DC_PRIVATE_ERROR_APPMAX ] || return "$ERROR_LIMIT"

  read -r "ERROR_${name?}" <<<"$_DC_PRIVATE_ERROR_APPCODEPOINT"
  export "ERROR_${name?}"
  readonly "ERROR_${name?}"
}

# TODO: introduce a reverse lookup method and have all return statements use it instead (guarantee no typo and no unintenional return 0
