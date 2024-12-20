#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

##########################################################################
# Command line flags
# ------
# This will process flags (arguments starting with a single or double -, with or without a value).
# Examples:
# * myscript -h
# * myscript --something=foo
# Flags value are available as DC_ARG_NAME (where NAME is the capitalized form of the flag).
# Flags must be passed before any other argument.
##########################################################################

dc::args::parse(){
  # Flag parsing
  local isFlag=true
  local x=0
  local i
  local name
  local value

  for i in "$@"; do
    # First argument not starting with a dash means we are done with flags and processing arguments
    [ "${i:0:1}" == "-" ] || isFlag=false
    if [ "$isFlag" == "false" ]; then
      x=$(( x + 1 ))
      # If ran twice (eg: testing) this is necessary
      if ! dc::args::exist "$x"; then
        read -r "DC_ARG_$x" <<<"$i"
        readonly "DC_ARG_$x"
        # readonly "DC_ARG_$x"="$i"
      fi
      continue
    fi

    # Otherwise, it's a flag, get everything after the leading -
    name="${i:1}"
    value=""
    # Remove a possible second char -
    [ "${name:0:1}" != "-" ] || name=${name:1}
    # Get the value, if we have an equal sign
    # shellcheck disable=SC2015
    [[ $name == *"="* ]] && value=${name#*=} || true
    # Now, Get the name
    name="${name%=*}"
    # Clean up the name: replace dash by underscore and uppercase everything
    name="$(dc::internal::varnorm "$name")"

    # Set the variable
    read -r "DC_ARG_${name}" <<<"$value"
    readonly "DC_ARG_${name}"
  done
}

dc::args::exist(){
  local slug
  slug="$(dc::internal::varnorm "$1")"
  local var="DC_ARG_$slug"
  [ "${!var+x}" ] || {
    dc::error::detail::set "$1"
    dc::error::throw ARGUMENT_MISSING || return
  }
}

dc::args::validate(){
  local slug
  slug="$(dc::internal::varnorm "$1")"
  local var="DC_ARG_$slug"
  local regexp="${2:-}"
  local optional="${3:-}"
  local caseInsensitive="${4:-}"

  local args=(-q)
  [ ! "$caseInsensitive" ] || args+=(-i)

  if [ ! "${!var+x}" ]; then
    [ ! "$optional" ] || return 0
    dc::error::throw ARGUMENT_MISSING "$slug" || return
  fi

  if [ "$regexp" ]; then
    # shellcheck disable=SC2015
    [ "$regexp" == "^$" ] && [ ! "${!var}" ] && return || true
    dc::wrapped::grep "${args[@]}" "$regexp" <<<"${!var}" || {
      dc::error::throw ARGUMENT_INVALID "$slug (${!var} vs. $regexp)" || return
    }
  fi
}
