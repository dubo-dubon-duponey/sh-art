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

# Flag parsing
for i in "$@"
do
  if [ ${i:0:1} != "-" ]; then
    break
  fi
  # Get everything after the leading -
  name=${i:1}
  # Remove a possible second char -
  [ ${name:0:1} != "-" ] || name=${name:1}
  # Get the value, if we have an equal sign
  value=
  [[ $name == *"="* ]] && value=${name#*=}
  # Now, Get the name
  name=${name%=*}
  # Clean up the name: replace dash by underscore and uppercase everything
  name=$(echo $name | tr "-" "_" | tr '[:lower:]' '[:upper:]')

  # Set the variable
  declare "DC_ARGV_$name"="$value"
  declare "DC_ARGE_$name"="true"
  # Shift the arg from the stack and move onto the next
  shift
done

x=0
for i in "$@"
do
  x=$(( x + 1 ))
  # Set the variable
  declare "DC_PARGV_$x"="$i"
  declare "DC_PARGE_$x"="$i"
done

# Makes the named argument mandatory on the command-line
dc::argv::flag::validate()
{
  local var="DC_ARGV_$(echo $1 | tr "-" "_" | tr '[:lower:]' '[:upper:]')"
  local varexist="DC_ARGE_$(echo $1 | tr "-" "_" | tr '[:lower:]' '[:upper:]')"
  local regexp="$2"
  local gf="${3:--E}"
  if [ "$regexp" ]; then
    local isvalid=$(echo "${!var}" | grep $gf "$regexp")
    if [ ! "$isvalid" ]; then
      dc::logger::error "Flag $(echo $1 | tr "_" "-" | tr '[:upper:]' '[:lower:]') is invalid. Must match $regexp - was: ${!var}"
      exit $ERROR_ARGUMENT_INVALID
    fi
  elif [ ! "${!varexist}" ]; then
    dc::logger::error "Flag $(echo $1 | tr "_" "-" | tr '[:upper:]' '[:lower:]') is required."
    exit $ERROR_ARGUMENT_MISSING
  fi
}

dc::argv::arg::validate()
{
  local var="DC_PARGV_$1"
  local varexist="DC_PARGE_$1"
  local regexp="$2"
  local gf="${3:--E}"
  if [ "$regexp" ]; then
    local isvalid=$(echo "${!var}" | grep $gf "$regexp")
    if [ ! "$isvalid" ]; then
      dc::logger::error "Argument $1 is invalid. Must match $regexp."
      exit $ERROR_ARGUMENT_INVALID
    fi
  elif [ ! "${!varexist}" ]; then
    dc::logger::error "Argument $1 is missing."
    exit $ERROR_ARGUMENT_MISSING
  fi
}
