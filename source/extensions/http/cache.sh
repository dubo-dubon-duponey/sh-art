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

  # If not GET or HEAD, ignore caching entirely
  if [ "$method" != "GET" ] && [ "$method" != "HEAD" ]; then
    DC_HTTP_CACHE=miss
    _dc_internal_ext::simplerequest "$url" "$method" "$@"
    return
  fi

  # Otherwise, look-up the cache first
  DC_HTTP_BODY=$(dc-ext::sqlite::select "dchttp" "content" "method='$method' AND url='$url'")
  DC_HTTP_STATUS=200
  DC_HTTP_CACHE=hit

  # Nothing? Or forced to refresh?
  if [ ! "$DC_HTTP_BODY" ] || [ "$DC_HTTP_CACHE_FORCE_REFRESH" ]; then
    # Request
    export DC_HTTP_CACHE=miss
    _dc_internal_ext::simplerequest "$url" "$method" "$@"
    # Insert in the database
    dc-ext::sqlite::insert "dchttp" "url, method, content" "'$url', '$method', '$DC_HTTP_BODY'"
  fi
}


_dc_internal_ext::simplerequest(){
  dc::http::request "$@"
  if [ "$DC_HTTP_STATUS" != 200 ]; then
    dc::logger::error "Failed fetching $1 $2"
    exit "$ERROR_NETWORK"
  fi
  DC_HTTP_BODY="$(base64 "$DC_HTTP_BODY")"
}
