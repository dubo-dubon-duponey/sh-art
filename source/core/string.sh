#!/usr/bin/env bash
##########################################################################
# String API
# ------
# Implements parts of the golang string API (https://golang.org/pkg/strings)
# Caveats:
# This is SLOW. It's ok for small payloads, but if you intend to process
# anything MB (or even KB?) large, you are better off using sed directly.
##########################################################################


# https://golang.org/pkg/strings/#Index
dc::string::index(){
  local varname="$1"
  local needle="$2"
  local x="${!varname%%$needle*}"
  if [ ! "$needle" ] && [ ! "${!varname}" ]; then
    result=0
    return
  fi
  result=-1
  if [ "$x" != "${!varname}" ]; then
    result=${#x}
  fi
}

# https://golang.org/pkg/strings/#LastIndex
dc::string::lastIndex(){
  local varname="$1"
  local needle="$2"
  if [ ! "$needle" ]; then
    if [ ! "${!varname}" ]; then
      result=0
    else
      result=1
    fi
    return
  fi
  result=-1
  local x="${!varname%$needle*}"
  if [ "$x" != "${!varname}" ]; then
    result=${#x}
  fi
}

# https://golang.org/pkg/strings/#Contains
dc::string::contains(){
  local varname="$1"
  local needle="$2"
  result=false
  if [[ "${!varname}" = *"$needle"* ]]; then
    result=true
  fi
}

# https://golang.org/pkg/strings/#Count
dc::string::count(){
  local varname="$1"
  local needle="$2"
  if [ ! "$needle" ]; then
    if [ ! "${!varname}" ]; then
      result=1
    else
      result=${!varname}
      result=${#result}
    fi
    return
  fi
  result=0
  local s=${!varname}
  local t
  until
    t=${s#*"$needle"}
    [ "$t" = "$s" ]
  do
    result=$((result + 1))
    s=$t
  done
}

# https://golang.org/pkg/strings/#Fields
dc::string::fields(){
  local i
  result=()
  for i in ${!1}; do
    result[${#result[@]}]=$i
  done
}

# https://golang.org/pkg/strings/#Join
dc::string::join(){
  local varname="$1[@]"
  local exresult=
  local i
  local sep=
  for i in "${!varname}"; do
    exresult="$exresult$sep$i"
    sep="$2"
  done
  printf "%s" "$exresult"
  # result="$exresult"
}


# https://golang.org/pkg/strings/#Split
dc::string::split(){
  dc::string::splitN "$1" "$2" -1
}

# https://golang.org/pkg/strings/#SplitAfter
dc::string::splitAfter(){
  dc::string::splitAfterN "$1" "$2" -1
}

# https://golang.org/pkg/strings/#SplitN
dc::string::splitN(){
  local _dcss_subject=${!1}
  local _dcss_segment

  if [ "${3}" == 0 ]; then
    # Should return nil
    return
  fi
  if [ ! "${_dcss_subject}" ]; then
    # Should return an empty array
    return
  fi

  # No sep, split on every single char
  if [ ! "${!2}" ]; then
    local i
    for (( i=0; i<${#_dcss_subject}; i++)); do
      printf "%s\0" "${_dcss_subject:$i:1}"
    done
    return
  fi

  # Otherwise
  local count=1
  while
    _dcss_segment="${_dcss_subject%%"${!2}"*}"
    [ "$_dcss_segment" != "$_dcss_subject" ] && ( [ "$3" == -1 ] || [ "$count" -le "$3" ] )
  do
    printf "%s\0" "$_dcss_segment"
    _dcss_subject=${_dcss_subject#*"${!2}"}
    count=$(( count + 1 ))
  done
  printf "%s\0" "$_dcss_subject"
}

XXXdc::string::splitNAWK(){
  local _dcss_subject=${!1}
  local _dcss_segment

  if [ "${3}" == 0 ]; then
    # Should return nil
    return
  fi
  if [ ! "${_dcss_subject}" ]; then
    # Should return an empty array
    return
  fi

  # No sep, split on every single char
  if [ ! "${!2}" ]; then
    local i
    for (( i=0; i<${#_dcss_subject}; i++)); do
      printf "%s\0" "${_dcss_subject:$i:1}"
    done
    return
  fi

  # Otherwise
  echo "$1" | awk -F "${!2}" -v end=$3 '{for(i=1;i<=end;i++){printf "%s\0", $i};}'
}



# https://golang.org/pkg/strings/#SplitAfterN
dc::string::splitAfterN(){
  local _dcss_subject=${!1}
  local _dcss_segment

  if [ "${3}" == 0 ]; then
    result=
    return
  fi
  result=()
  # No subject, empty array
  if [ ! "${_dcss_subject}" ]; then
    return
  fi

  # No sep, split on every single char
  if [ ! "${!2}" ]; then
    local i
    for (( i=0; i<${#_dcss_subject}; i++)); do
      result[${#result[@]}]=${_dcss_subject:$i:1}
    done
    return
  fi

  # Otherwise
  local count=1
  while
    _dcss_segment=${_dcss_subject#*"${!2}"}
    [ "$_dcss_segment" != "$_dcss_subject" ] && ( [ "$3" == -1 ] || [ "$count" -le "$3" ] )
  do
    if [ "${_dcss_subject%%"${!2}"*}" == "${_dcss_subject}" ]; then
      result[${#result[@]}]=$_dcss_subject
    else
      result[${#result[@]}]=${_dcss_subject%%"${!2}"*}${!2}
    fi
    _dcss_subject=$_dcss_segment
    count=$(( count + 1 ))
  done
  result[${#result[@]}]=$_dcss_subject
}

# https://golang.org/pkg/strings/#Repeat
dc::string::repeat(){
  local varname="$1"
  result=
  local i
  for (( i=1; i<=$2; i++)); do
    result=$result${!varname}
  done
}

# https://golang.org/pkg/strings/#HasPrefix
dc::string::hasPrefix(){
  local varname="$1"
  local needle="$2"
  result=false
  if [[ "${!varname}" = "$needle"* ]]; then
    result=true
  fi
}

# https://golang.org/pkg/strings/#HasSuffix
dc::string::hasSuffix(){
  local varname="$1"
  local needle="$2"
  result=false
  if [[ "${!varname}" = *"$needle" ]]; then
    result=true
  fi
}

# https://golang.org/pkg/strings/#Replace
dc::string::replace(){
  local v
  local arr=()
  while IFS= read -r -d '' -a v; do
    arr[${#arr[@]}]="$v"
  done < <(dc::string::splitN $1 "$2" ${4:--1})
  result=$(dc::string::join arr "$3")
}

# ***************** OK
dc::string::toLower(){
  if [ ! "${1}" ]; then
    cat /dev/stdin | tr '[:upper:]' '[:lower:]'
  else
    printf "%s" "${!1}" | tr '[:upper:]' '[:lower:]'
  fi
}

# ***************** OK
dc::string::toUpper(){
  if [ ! "${1}" ]; then
    cat /dev/stdin | tr '[:lower:]' '[:upper:]'
  else
    printf "%s" "${!1}" | tr '[:lower:]' '[:upper:]'
  fi
}

dc::string::trimLeft(){
  local pattern="$2"
  local needle=
  dc::string::contains pattern "]"
  if [ $result == true ]; then
    needle="]"
    dc::string::replace pattern needle ""
    pattern="]$result"
  fi
  dc::string::contains pattern "-"
  if [ $result == true ]; then
    needle="-"
    dc::string::replace pattern needle ""
    pattern="$result-"
  fi
  result=$(echo -e "${!1}" | sed -E "s/^[$pattern]*//")
}

dc::string::trimRight(){
  local pattern="$2"
  local needle=
  dc::string::contains pattern "]"
  if [ $result == true ]; then
    needle="]"
    dc::string::replace pattern needle ""
    pattern="]$result"
  fi
  dc::string::contains pattern "-"
  if [ $result == true ]; then
    needle="-"
    dc::string::replace pattern needle ""
    pattern="$result-"
  fi
  result=$(echo -e "${!1}" | sed -E "s/[$pattern]*\$//")
}

dc::string::trim(){
  local pattern="$2"
  local rep="/"
  dc::string::replace pattern rep "\\/"
  pattern="$result"
  dc::string::trimLeft "$1" "$pattern"
  dc::string::trimRight "result" "$pattern"
}
# ***************** OK
dc::string::trimSpace(){
  if [ ! "${1}" ]; then
    cat /dev/stdin | sed -E "s/^[[:space:]\n]*//" | sed -E "s/[[:space:]\n]*\$//"
  else
    printf "%s" "${!1}" | sed -E "s/^[[:space:]\n]*//" | sed -E "s/[[:space:]\n]*\$//"
  fi
}

dc::string::trimPrefix(){
  dc::string::hasPrefix "$1" "$2"
  if [ $result == true ]; then
    result=${!1:${#2}}
  else
    result=${!1}
  fi
}

dc::string::trimSuffix(){
  dc::string::hasSuffix "$1" "$2"
  local lname=${!1}
  if [ $result == true ]; then
    result=${!1:0:(( ${#lname} - ${#2} ))}
  else
    result=${!1}
  fi
}
