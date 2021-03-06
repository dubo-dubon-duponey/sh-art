#!/usr/bin/env bash
##########################################################################
# HTTP client
# ------
# From a call to dc::http::request consumer gets the following variables:
# - DC_HTTP_STATUS: 3 digit status code after redirects
# - DC_HTTP_REDIRECTED: final redirect location, if any
# - DC_HTTP_HEADERS: list of the response headers keys
# - DC_HTTP_HEADER_XYZ - where XYZ is the header key, for all headers that have been set
# - DC_HTTP_BODY: temporary filename containing the raw body
#
# This module depends only on logger
# Any non http failure will result in an empty status code

#####################################
# Configuration hooks
#####################################

dc::configure::http::leak(){
  dc::logger::warning "[dc-http] YOU ASKED FOR FULL-BLOWN HTTP DEBUGGING: THIS WILL LEAK SENSITIVE INFORMATION TO STDERR."
  dc::logger::warning "[dc-http] Unless you are debugging actively and you really know what you are doing, you MUST STOP NOW."
  _DC_PRIVATE_HTTP_REDACT=
}

dc::configure::http::insecure(){
  dc::logger::warning "[dc-http] YOU ARE USING THE INSECURE FLAG."
  dc::logger::warning "[dc-http] This basically means your communication with the server is as secure as if there was NO TLS AT ALL."
  dc::logger::warning "[dc-http] Unless you really, really, REALLY know what you are doing, you MUST RECONSIDER NOW."
  _DC_PRIVATE_HTTP_INSECURE=true
}

#####################################
# Public API
#####################################

DC_HTTP_STATUS=
DC_HTTP_REDIRECTED=
DC_HTTP_HEADERS=
DC_HTTP_BODY=

# Dumps all relevant data from the last HTTP request to the logger (warning)
# XXX fixme: this will dump sensitive information and should be
dc::http::dump::headers() {
  dc::logger::warning "[dc-http] status: $DC_HTTP_STATUS"
  dc::logger::warning "[dc-http] redirected to: $DC_HTTP_REDIRECTED"

  dc::logger::warning "[dc-http] headers:"

  local value

  for i in $DC_HTTP_HEADERS; do
    value=DC_HTTP_HEADER_$i

    # Expunge
    [ "$_DC_PRIVATE_HTTP_REDACT" ] && [[ "${_DC_PRIVATE_HTTP_PROTECTED_HEADERS[*]}" == *"$i"* ]] && value=REDACTED
    dc::logger::warning "[dc-http] $i: ${!value}"
  done
}

dc::http::dump::body() {
  dc::optional jq
  if ! dc::logger::warning "$(jq . "$DC_HTTP_BODY" 2>/dev/null)"; then
    dc::logger::warning "$(cat "$DC_HTTP_BODY")"
  fi
}

# A helper to encode uri fragments
dc::http::uriencode() {
  local s
  s="${*//'%'/%25}"
  s="${s//' '/%20}"
  s="${s//'"'/%22}"
  s="${s//'#'/%23}"
  s="${s//'$'/%24}"
  s="${s//'&'/%26}"
  s="${s//'+'/%2B}"
  s="${s//','/%2C}"
  s="${s//'/'/%2F}"
  s="${s//':'/%3A}"
  s="${s//';'/%3B}"
  s="${s//'='/%3D}"
  s="${s//'?'/%3F}"
  s="${s//'@'/%40}"
  s="${s//'['/%5B}"
  s="${s//']'/%5D}"
  printf %s "$s"
}

dc::http::request(){
  dc::require curl
  # Reset result data
  DC_HTTP_STATUS=
  DC_HTTP_REDIRECTED=
  local i
  for i in $DC_HTTP_HEADERS; do
    read -r "DC_HTTP_HEADER_$i" < <(printf "")
  done
  DC_HTTP_HEADERS=
  DC_HTTP_BODY=

  # Grab the named parameters first
  local url="$1"
  local method="${2:-HEAD}"
  local payloadFile="$3"
  shift
  shift
  shift

  # Build the curl request
  local filename
  local curlOpts=( "$url" "-v" "-L" "-s" )

  # Special case HEAD, damn you curl
  if [ "$method" == "HEAD" ]; then
    filename=/dev/null
    curlOpts[${#curlOpts[@]}]="-I"
  else
    filename="$(dc::portable::mktemp dc::http::request)"
    curlOpts[${#curlOpts[@]}]="-X"
    curlOpts[${#curlOpts[@]}]="$method"
  fi
  curlOpts[${#curlOpts[@]}]="-o$filename"

  if [ "$payloadFile" ]; then
    curlOpts[${#curlOpts[@]}]="--data-binary"
    curlOpts[${#curlOpts[@]}]="@$payloadFile"
  fi

  local i

  # Add in all remaining parameters as additional headers
  for i in "$@"; do
    curlOpts[${#curlOpts[@]}]="-H"
    curlOpts[${#curlOpts[@]}]="$i"
  done

  if [ "$_DC_PRIVATE_HTTP_INSECURE" ]; then
    curlOpts[${#curlOpts[@]}]="--insecure"
    curlOpts[${#curlOpts[@]}]="--proxy-insecure"
  fi

  _dc_internal::http::logcommand

  # Do it!
  local key
  local value
  local isRedirect
  local line

  while read -r i; do
    # Ignoring the leading character, and trim for content
    line=$(printf "%s" "${i:1}" | sed -E "s/^[[:space:]]*//" | sed -E "s/[[:space:]]*\$//")
    # Ignore empty content
    [ "$line" ] || continue

    # Now, detect leading char
    case ${i:0:1} in
      ">")
        # Request
      ;;
      "<")
        # Response

        # This is a header
        if [[ "$line" == *":"* ]]; then
          key=$(printf "%s" "${line%%:*}" | tr "-" "_" | tr '[:lower:]' '[:upper:]')
          value=${line#*: }

          if [ ! "$isRedirect" ]; then
            [ ! "$DC_HTTP_HEADERS" ] && DC_HTTP_HEADERS=$key || DC_HTTP_HEADERS="$DC_HTTP_HEADERS $key"
            read -r "DC_HTTP_HEADER_$key" < <(printf "%s" "$value")
          elif [ "$key" == "LOCATION" ]; then
            DC_HTTP_REDIRECTED=$value
          fi

          # Expunge what we log
          [ "$_DC_PRIVATE_HTTP_REDACT" ] && [[ "${_DC_PRIVATE_HTTP_PROTECTED_HEADERS[*]}" == *"$key"* ]] && value=REDACTED
          dc::logger::debug "[dc-http] $key | $value"
          continue
        fi

        # Not a header, then it's a status line
        isRedirect=
        if ! printf "%s" "$line" | grep -qE "^HTTP/[0-9.]+ [0-9]+"; then
          dc::logger::warning "Ignoring random curl output (XXX FIXME multiline header): $i"
          continue
        fi

        DC_HTTP_STATUS=${line#* }
        DC_HTTP_STATUS=${DC_HTTP_STATUS%% *}
        [[ ${DC_HTTP_STATUS:0:1} == "3" ]] && isRedirect=true
        dc::logger::info "[dc-http] status: $DC_HTTP_STATUS"
      ;;
      "}")
        # Bytes sent
      ;;
      "{")
        # Bytes received
      ;;
      "*")
        # Info
      ;;
    esac
    # headers[${#headers[@]}]="$t"
  done < <(
    curl "${curlOpts[@]}" 2>&1
  )
  DC_HTTP_BODY="$filename"
}

#####################################
# Private
#####################################

_DC_PRIVATE_HTTP_REDACT=true
_DC_PRIVATE_HTTP_INSECURE=
# Given the nature of the matching we do, any header that contains these words will match, including proxy-authorization and set-cookie
_DC_PRIVATE_HTTP_PROTECTED_HEADERS=( authorization cookie user-agent )

_dc_internal::http::logcommand() {
  local output="curl"
  local i
  for i in "${curlOpts[@]}"; do
    # -args are logged as-is
    if [ "${i:0:1}" == "-" ]; then
      output="$output $i"
      continue
    fi

    # If we redact, filter out sensitive headers
    if [ "$_DC_PRIVATE_HTTP_REDACT" ]; then
      # XXX this is overly aggressive, and will match any header that is a substring of one of the protected headers
      case "${_DC_PRIVATE_HTTP_PROTECTED_HEADERS[*]}" in
        *$(printf "%s" ${i%%:*} | tr '[:upper:]' '[:lower:]')*)
          output="$output \"${i%%:*}: REDACTED\""
          continue
        ;;
      esac
    fi

    # Otherwise, pass them in
    output="$output \"$i\" "
  done

  # dc::logger::info "[dc-http] ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★"
  dc::logger::info "[dc-http] $output"
  # dc::logger::info "[dc-http] ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★"
}
