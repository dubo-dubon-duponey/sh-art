#!/usr/bin/env bash

_DC_INTERNAL_ERROR_CODEPOINT=143
_DC_INTERNAL_ERROR_DETAIL=

dc::error::register(){
  local name="$1"

  dc::argument::check name "$DC_TYPE_VARIABLE"

  _DC_INTERNAL_ERROR_CODEPOINT=$(( _DC_INTERNAL_ERROR_CODEPOINT + 1 ))

  # read -r "${name?}" < <(printf "%s" "$_DC_INTERNAL_ERROR_CODEPOINT")
  declare -g "${name?}"="$_DC_INTERNAL_ERROR_CODEPOINT"
  export "${name?}"
  readonly "${name?}"
}

dc::error::lookup(){
  local code="$1"
  local errname

  dc::argument::check code "$DC_TYPE_UNSIGNED"

  # XXX depends on grep here
  errname="$(env | dc::internal::grep "^ERROR_[^=]+=$code$")"
  printf "%s" "${errname%=*}"
}

dc::error::detail::set(){
  _DC_INTERNAL_ERROR_DETAIL="$1"
}

dc::error::detail::get(){
  printf "%s" "$_DC_INTERNAL_ERROR_DETAIL"
}
