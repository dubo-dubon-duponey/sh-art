#!/usr/bin/env bash
##########################################################################
# Command line flags
# ------
# This will process flags (arguments starting with a single or double -, with or without a value).
# Examples:
# * myscript -h
# * myscript --something=foo
# Flags value are available as DC_ARGV_NAME (where NAME is the capitalized form of the flag).
# If a flag has been passed (with or without a value), DC_ARGE_NAME will be set
# Flags must be passed before any other argument.
##########################################################################

_dc_internal::parse_args(){
  # Flag parsing
  local isFlag=true
  local x=0
  local i
  local name
  local value

  for i in "$@"
  do
    # First argument no starting with a dash means we are done with flags and processing arguments
    [ "${i:0:1}" == "-" ] || isFlag=false
    if [ "$isFlag" == "false" ]; then
      x=$(( x + 1 ))
      n=DC_PARGE_$x
      if [ ! "${!n}" ]; then
        # shellcheck disable=SC2140
        readonly "DC_PARGE_$x"=true
        # shellcheck disable=SC2140
        readonly "DC_PARGV_$x"="$i"
      fi
      continue
    fi

    # Otherwise, it's a flag, get everything after the leading -
    name="${i:1}"
    value=
    # Remove a possible second char -
    [ "${name:0:1}" != "-" ] || name=${name:1}
    # Get the value, if we have an equal sign
    [[ $name == *"="* ]] && value=${name#*=}
    # Now, Get the name
    name=${name%=*}
    # Clean up the name: replace dash by underscore and uppercase everything
    name=$(printf "%s" "$name" | tr "-" "_" | tr '[:lower:]' '[:upper:]')

    # Set the variable
    # shellcheck disable=SC2140
    readonly "DC_ARGV_$name"="$value"
    # shellcheck disable=SC2140
    readonly "DC_ARGE_$name"=true
  done
}

# XXX should this be internal? called by another higher-level method?
_dc_internal::parse_args "$@"

# Makes the named argument mandatory on the command-line
dc::args::flag::validate()
{
  local var
  local varexist
  local regexp="$2"
  local extended="-E"
  local optional="$3"
  local caseInsensitive="$4"

  [ ! "$_DC_PRIVATE_GNUGREP" ] || extended="-P"
  [ ! "$caseInsensitive" ] || extended="${extended}i"
  var="DC_ARGV_$(printf "%s" "$1" | tr "-" "_" | tr '[:lower:]' '[:upper:]')"
  varexist="DC_ARGE_$(printf "%s" "$1" | tr "-" "_" | tr '[:lower:]' '[:upper:]')"

  if [ ! "${!varexist}" ]; then
    [ ! "$optional" ] || return
    dc::logger::error "Required flag \"$(printf "%s" "$1" | tr "_" "-" | tr '[:upper:]' '[:lower:]')\" is missing."
    exit "$ERROR_ARGUMENT_MISSING"
  fi

  if [ "$regexp" ]; then
    if [ "$regexp" == "^$" ] && [ ! "${!var}" ]; then
      return
    fi
    if ! printf "%s" "${!var}" | grep -q "$extended" "$regexp"; then
      dc::logger::error "Flag \"$(printf "%s" "$1" | tr "_" "-" | tr '[:upper:]' '[:lower:]')\" is invalid. Provided value \"${!var}\" does not match \"$regexp\"."
      exit "$ERROR_ARGUMENT_INVALID"
    fi
  fi
}

dc::args::arg::validate()
{
  local var="DC_PARGV_$1"
  local varexist="DC_PARGE_$1"
  local regexp="$2"
  local extended="-E"
  local optional="$3"
  local caseInsensitive="$4"

  [ ! "$_DC_PRIVATE_GNUGREP" ] || extended="-P"
  [ ! "$caseInsensitive" ] || extended="${extended}i"

  if [ ! "${!varexist}" ]; then
    [ ! "$optional" ] || return
    dc::logger::error "Required argument \"$1\" is missing."
    exit "$ERROR_ARGUMENT_MISSING"
  fi

  if [ "$regexp" ]; then
    if [ "$regexp" == "^$" ] && [ ! "${!var}" ]; then
      return
    fi
    if ! printf "%s" "${!var}" | grep -q "$extended" "$regexp"; then
      dc::logger::error "Argument \"$1\" is invalid. Provided value \"${!var}\" does not match \"$regexp\"."
      exit "$ERROR_ARGUMENT_INVALID"
    fi
  fi
}
