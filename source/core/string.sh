#!/usr/bin/env bash
##########################################################################
# String API
# ------
# Implements parts of the golang string API (https://golang.org/pkg/strings)
# Caveats:
# This is SLOW. It's ok for small payloads, but if you intend to process
# anything MB (or even KB?) large, you are better off using sed directly.
##########################################################################

# https://golang.org/pkg/strings/#Split
dc::string::split(){
  dc::string::splitN "$1" "$2" -1
}

# https://golang.org/pkg/strings/#SplitN
dc::string::splitN(){
  local _dcss_subject=${!1}
  local sep="${!2}"
  local _dcss_count
  _dcss_count="$(printf "%s" "$3" | grep -E '^[0-9-]+$')"
  _dcss_count=${_dcss_count:--1}

  if [ "$_dcss_count" == 0 ]; then
    # Should return nil
    return
  fi
  if [ ! "${_dcss_subject}" ]; then
    # Should return an empty array
    return
  fi

  # No sep, split on every single char
  if [ ! "$sep" ]; then
    local i
    for (( i=0; i<${#_dcss_subject} && (_dcss_count == -1 || i<_dcss_count); i++)); do
      printf "%s\\0" "${_dcss_subject:$i:1}"
    done
    return
  fi

  # Otherwise
  local count=1
  local _dcss_segment
  while
    _dcss_segment="${_dcss_subject%%"$sep"*}"
    [ "${#_dcss_segment}" != "${#_dcss_subject}" ] && { [ "$_dcss_count" == -1 ] || [ "$count" -lt "$_dcss_count" ]; }
  do
    printf "%s\\0" "$_dcss_segment"
    local tt=$(( ${#_dcss_segment} + ${#sep} ))
    _dcss_subject=${_dcss_subject:${tt}}
    count=$(( count + 1 ))
  done
  printf "%s\\0" "$_dcss_subject"
}

# https://golang.org/pkg/strings/#Join
dc::string::join(){
  local varname="$1[@]"
  local i
  local sep=
  for i in "${!varname}"; do
    printf "%s" "$sep" "$i"
    sep="$2"
  done
}

# ***************** OK
dc::string::toLower(){
  if [ ! "${1}" ]; then
    tr '[:upper:]' '[:lower:]' < /dev/stdin
  else
    printf "%s" "${!1}" | tr '[:upper:]' '[:lower:]'
  fi
}

# ***************** OK
dc::string::toUpper(){
  if [ ! "${1}" ]; then
    tr '[:lower:]' '[:upper:]' < /dev/stdin
  else
    printf "%s" "${!1}" | tr '[:lower:]' '[:upper:]'
  fi
}

# ***************** OK
dc::string::trimSpace(){
  if [ ! "${1}" ]; then
    sed -E "s/^[[:space:]\\n]*//" < /dev/stdin | sed -E "s/[[:space:]\\n]*\$//"
  else
    printf "%s" "${!1}" | sed -E "s/^[[:space:]\\n]*//" | sed -E "s/[[:space:]\\n]*\$//"
  fi
}
