#!/usr/bin/env bash

DC_HTTP_CACHE_FORCE_REFRESH=

dc-ext::http-cache::init(){
  dc-ext::sqlite::ensure "dchttp" "method TEXT, url TEXT, content BLOB, PRIMARY KEY(method, url)"
}

dc-ext::http-cache::request(){
  local url="$1"
  local method
  method="$(printf "%s" "$2" | tr '[:lower:]' '[:upper:]')"
  shift
  shift

  local body

  # If not GET or HEAD, ignore caching entirely
  if [ "$method" != "GET" ] && [ "$method" != "HEAD" ]; then
    DC_HTTP_CACHE=miss
    _dc_internal_ext::simplerequest "$url" "$method" "$@"
    return
  fi

  # Otherwise, look-up the cache first
  body=$(dc-ext::sqlite::select "dchttp" "content" "method='$method' AND url='$url'")
  DC_HTTP_STATUS=200
  DC_HTTP_CACHE=hit

  # Nothing? Or forced to refresh?
  if [ ! "$body" ] || [ "$DC_HTTP_CACHE_FORCE_REFRESH" ]; then
    # Request
    export DC_HTTP_CACHE=miss
    body="$(_dc_internal_ext::simplerequest "$url" "$method" "" /dev/stdout "$@")"
    # Insert in the database
    dc-ext::sqlite::insert "dchttp" "url, method, content" "'$url', '$method', '$body'"
  fi
  printf "%s" "$body"
}


_dc_internal_ext::simplerequest(){
  dc::http::request "$@" | base64 || return
  [ "$DC_HTTP_STATUS" == 200 ] || return "$ERROR_NETWORK"
}
