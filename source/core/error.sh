#!/usr/bin/env bash
##########################################################################
# Error management
# ------
# - register to declare new error codes
# - detail:set and get to provide context for errors when they happen
# - lookup to get a readable constant out of an error code
##########################################################################

_DC_INTERNAL_ERROR_CODEPOINT=143
_DC_INTERNAL_ERROR_APPCODEPOINT=2
_DC_INTERNAL_ERROR_DETAIL=

dc::error::register(){
  local name="$1"

  dc::argument::check name "$DC_TYPE_VARIABLE"

  _DC_INTERNAL_ERROR_CODEPOINT=$(( _DC_INTERNAL_ERROR_CODEPOINT + 1 ))

  # XXX bash3
  # declare -g "${name?}"="$_DC_INTERNAL_ERROR_CODEPOINT"
  read -r "${name?}" <<<"$_DC_INTERNAL_ERROR_CODEPOINT"
  export "${name?}"
  readonly "${name?}"
}

dc::error::appregister(){
  local name="$1"

  dc::argument::check name "$DC_TYPE_VARIABLE"

  _DC_INTERNAL_ERROR_APPCODEPOINT=$(( _DC_INTERNAL_ERROR_APPCODEPOINT + 1 ))

  read -r "${name?}" <<<"$_DC_INTERNAL_ERROR_CODEPOINT"
  export "${name?}"
  readonly "${name?}"
}

dc::error::lookup(){
  local code="$1"
  local errname

  dc::argument::check code "$DC_TYPE_UNSIGNED"

  errname="$(env | dc::internal::grep "^ERROR_[^=]+=$code$")"
  printf "%s" "${errname%=*}"
}

dc::error::detail::set(){
  _DC_INTERNAL_ERROR_DETAIL="$1"
}

dc::error::detail::get(){
  printf "%s" "$_DC_INTERNAL_ERROR_DETAIL"
}
