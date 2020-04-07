#!/usr/bin/env bash

#python -m SimpleHTTPServer 12345

# shellcheck source=source/cli/http/base-errors.sh
. source/cli/http/base-errors.sh

testHTTPDNSResolutionFailure(){
  local exitcode

  exitcode=0
  # DNS resolution failure
  result=$(dc-http -s -m=HEAD https://WHATEVERTHISISITWILLFAIL) || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} exit code" "NETWORK" "$(dc::error::lookup $exitcode)"
  dc-tools::assert::equal "${FUNCNAME[0]} result" "$result" ""
}

testHTTPNoServer(){
  local exitcode

  exitcode=0
  # No response at that address
  result=$(dc-http -s -m=HEAD https://locahost:12345) || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} exit code" "NETWORK" "$(dc::error::lookup $exitcode)"
  dc-tools::assert::equal "${FUNCNAME[0]} result" "$result" ""
}

testHTTPUnexpectedTLS(){
  local exitcode

  exitcode=0
  # HTTP on HTTPS
  result=$(dc-http -s -m=HEAD https://www.google.com:80) || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} exit code" "NETWORK" "$(dc::error::lookup $exitcode)"
  dc-tools::assert::equal "${FUNCNAME[0]} result" "$result" ""
}

testHTTPUnexpectedNoTLS(){
  local exitcode

  exitcode=0
  # HTTPS on HTTP
  result=$(dc-http -s -m=HEAD http://www.google.com:443) || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} exit code" "NETWORK" "$(dc::error::lookup $exitcode)"
  dc-tools::assert::equal "${FUNCNAME[0]} result" "$result" ""
}

testHTTPRedirect(){
  local exitcode

  exitcode=0
  # Redirect
  result=$(dc-http -s -m=HEAD https://google.com) || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} exit code" "0" "$exitcode"

  status="$(printf "%s" "$result" | jq -r -c .status)"
  redirected="$(printf "%s" "$result" | jq -r -c .redirected)"
  body="$(printf "%s" "$result" | jq -r -c .body)"
  headers="$(printf "%s" "$result" | jq -r -c .headers)"
  server="$(printf "%s" "$headers" | jq -r -c .SERVER)"
  dc-tools::assert::equal "${FUNCNAME[0]} status" "$status" "200"
  dc-tools::assert::equal "${FUNCNAME[0]} redirected" "$redirected" "https://www.google.com/"
  dc-tools::assert::equal "${FUNCNAME[0]} body" "$body" ""
  dc-tools::assert::equal "${FUNCNAME[0]} server" "$server" "gws"
}

testHTTPValidHEAD(){
  local exitcode

  exitcode=0
  # Valid HEAD request
  result=$(dc-http -s -m=HEAD https://www.google.com) || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} exit code" "0" "$exitcode"

  status="$(printf "%s" "$result" | jq -r -c .status)"
  redirected="$(printf "%s" "$result" | jq -r -c .redirected)"
  body="$(printf "%s" "$result" | jq -r -c .body)"
  headers="$(printf "%s" "$result" | jq -r -c .headers)"
  dc-tools::assert::equal "${FUNCNAME[0]} status" "$status" "200"
  dc-tools::assert::equal "${FUNCNAME[0]} redirected" "$redirected" ""
  dc-tools::assert::equal "${FUNCNAME[0]} body" "$body" ""
}

testHTTPValidGET(){
  local exitcode

  exitcode=0
  # Valid GET request
  result=$(dc-http -s -m=GET https://registry-1.docker.io/v2) || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} exit code" "0" "$exitcode"

  status="$(printf "%s" "$result" | jq -r -c .status)"
  redirected="$(printf "%s" "$result" | jq -r -c .redirected)"
  body="$(printf "%s" "$result" | jq -r -c .body | dc::wrapped::base64d)"
  headers="$(printf "%s" "$result" | jq -r -c .headers)"
  dc-tools::assert::equal "${FUNCNAME[0]} status" "$status" "401"
  dc-tools::assert::equal "${FUNCNAME[0]} redirected" "$redirected" "/v2/"
  dc-tools::assert::equal "${FUNCNAME[0]} body" '{"errors":[{"code":"UNAUTHORIZED","message":"authentication required","detail":null}]}' "$body"
}
