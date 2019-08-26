#!/usr/bin/env bash

#####################################
# Private
#####################################

_DC_INTERNAL_HTTP_REDACT=true
# Given the nature of the matching we do, any header that contains these words will match, including proxy-authorization and set-cookie
_DC_INTERNAL_HTTP_PROTECTED_HEADERS=( authorization cookie user-agent )

DC_HTTP_STATUS=
DC_HTTP_REDIRECTED=
DC_HTTP_HEADERS=()

dc::wrapped::curl(){
  local err
  local ex
  local line
  local key
  local value
  local isRedirect

  # Reset everything
  local i
  for i in "${DC_HTTP_HEADERS[@]}"; do
    read -r "DC_HTTP_HEADER_$i" <<< ""
  done
  DC_HTTP_HEADERS=()
  DC_HTTP_STATUS=
  DC_HTTP_REDIRECTED=

  exec 3>&1
  err="$(curl "$@" 2>&1 1>&3)"
  ex="$?"
  if [ "$ex" != 0 ]; then
    exec 3>&-
    [ "$ex" == 7 ] && return "$ERROR_CURL_CONNECTION_FAILED"
    [ "$ex" == 6 ] && return "$ERROR_CURL_DNS_FAILED"
    dc::error::detail::set "$err"
    return "$ERROR_BINARY_UNKNOWN_ERROR"
  fi

  while read -r line; do
    # > request
    # } bytes sent
    # { bytes received
    # * info
    [ "${line:0:1}" != "<" ] && continue

    # Ignoring the leading character, and trim for content
    line=$(printf "%s" "${line:1}" | sed -E "s/^[[:space:]]*//" | sed -E "s/[[:space:]]*\$//")

    # Ignore empty content
    [ "$line" ] || continue

    # Is it a status line
    if printf "%s" "$line" | dc::internal::grep -q "^HTTP/[0-9.]+ [0-9]+"; then
      isRedirect=
      line="${line#* }"
      DC_HTTP_STATUS="${line%% *}"
      [ "${DC_HTTP_STATUS:0:1}" == "3" ] && isRedirect=true
      dc::logger::debug "[dc-http] status: $DC_HTTP_STATUS"
      continue
    fi

    # Not a header? Move on
    [[ "$line" == *":"* ]] || continue

    # Parse header
    key="$(printf "%s" "${line%%:*}" | tr "-" "_" | tr '[:lower:]' '[:upper:]')"
    value="${line#*: }"

    # Expunge what we log
    [ "$_DC_INTERNAL_HTTP_REDACT" ] && [[ "${_DC_INTERNAL_HTTP_PROTECTED_HEADERS[*]}" == *"$key"* ]] && value=REDACTED
    dc::logger::debug "[dc-http] $key | $value"

    if [ "$isRedirect" ]; then
      [ "$key" == "LOCATION" ] && export DC_HTTP_REDIRECTED="$value"
      continue
    fi
    DC_HTTP_HEADERS+=("$key")
    read -r "DC_HTTP_HEADER_$key" < <(printf "%s" "$value")

  done < <(printf "%s" "$err")

  exec 3>&-
}

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
  _DC_INTERNAL_HTTP_REDACT=
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

# Dumps all relevant data from the last HTTP request to the logger (warning)
# XXX fixme: this will dump sensitive information and should be
dc::http::dump::headers() {
  dc::logger::warning "[dc-http] status: $DC_HTTP_STATUS"
  dc::logger::warning "[dc-http] redirected to: $DC_HTTP_REDIRECTED"
  dc::logger::warning "[dc-http] headers:"

  # shellcheck disable=SC2034
  local redacted=REDACTED
  local value
  local i

  for i in "${DC_HTTP_HEADERS[@]}"; do
    value=DC_HTTP_HEADER_$i
    [ "$_DC_INTERNAL_HTTP_REDACT" ] && [[ "${_DC_INTERNAL_HTTP_PROTECTED_HEADERS[*]}" == *"$i"* ]] && value=redacted
    dc::logger::warning "[dc-http] $i: ${!value}"
  done
}

dc::http::request(){
  dc::require curl || return

  # Grab the named parameters first
  local url="$1"
  local method="${2:-HEAD}"
  local payloadFile="$3"
  local outputFile="${4:-/dev/stdout}"
  shift
  shift
  shift
  shift

  # Build the curl request
  local curlOpts=( "$url" "-v" "-L" "-s" )
  local output="curl"

  # Special case HEAD, damn you curl
  [ "$method" == "HEAD" ]           && curlOpts+=("-I" "-o/dev/null") \
                                    || curlOpts+=("-X" "$method" "-o$outputFile")

  [ "$payloadFile" ]                && curlOpts+=("--data-binary" "@$payloadFile")
  [ "$_DC_PRIVATE_HTTP_INSECURE" ]  && curlOpts+=("--insecure" "--proxy-insecure")

  # Add in all remaining parameters as additional headers
  for i in "$@"; do
    curlOpts+=("-H" "$i")
  done

  # Log the command
  for i in "$@"; do
    # -args are logged as-is
    [ "${i:0:1}" == "-" ] && output="$output $i" && continue

    # If we redact, filter out sensitive headers
    # XXX this is overly aggressive, and will match any header that is a substring of one of the protected headers
    [ "$_DC_INTERNAL_HTTP_REDACT" ] && [[ "${_DC_INTERNAL_HTTP_PROTECTED_HEADERS[*]}" == *$(printf "%s" "${i%%:*}" | tr '[:upper:]' '[:lower:]')* ]] \
      && output="$output \"${i%%:*}: REDACTED\"" \
      && continue

    # Otherwise, pass them in as-is
    output="$output \"$i\" "
  done

  dc::logger::debug "[dc-http] $output"

  dc::wrapped::curl "${curlOpts[@]}"
}
