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
  local subject=${!1}
  local sep="${!2}"
  local count="${3:--1}"
  local counter=1
  local dcss_segment

  [ ! "$count" ] || dc::argument::check count "$DC_TYPE_INTEGER" || return

  if [ "$count" == 0 ]; then
    # Should return nil
    return
  fi
  if [ ! "${subject}" ]; then
    # Should return an empty array
    return
  fi

  # No sep, split on every single char
  if [ ! "$sep" ]; then
    local i
    for (( i=0; i<${#subject} && (count == -1 || i<count); i++)); do
      printf "%s\\0" "${subject:$i:1}"
    done
    return
  fi

  # Otherwise
  while
    dcss_segment="${subject%%"$sep"*}"
    [ "${#dcss_segment}" != "${#subject}" ] && { [ "$count" == -1 ] || [ "$counter" -lt "$count" ]; }
  do
    printf "%s\\0" "$dcss_segment"
    local tt=$(( ${#dcss_segment} + ${#sep} ))
    subject=${subject:${tt}}
    counter=$(( counter + 1 ))
  done
  printf "%s\\0" "$subject"
}

# https://golang.org/pkg/strings/#Join
dc::string::join(){
  local varname="$1[@]"
  local i
  local sep=

  for i in "${!varname:-}"; do
    printf "%s%s" "$sep" "$i"
    sep="${2:-}"
  done
}

# ***************** OK
# shellcheck disable=SC2120
dc::string::toLower(){
  local fd="${1:-/dev/stdin}"

  tr '[:upper:]' '[:lower:]' < "$fd"
}

# ***************** OK
# shellcheck disable=SC2120
dc::string::toUpper(){
  local fd="${1:-/dev/stdin}"

  tr '[:lower:]' '[:upper:]' < "$fd"
}

# ***************** OK
# shellcheck disable=SC2120
dc::string::trimSpace(){
  local fd="${1:-/dev/stdin}"

  sed -E "s/^[[:space:]\n]*//" < "$fd" | sed -E "s/[[:space:]\n]*\$//"
}
