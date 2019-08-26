#!/usr/bin/env bash


#python -m SimpleHTTPServer 12345

testHTTPDNSResolutionFailure(){
  # DNS resolution failure
  result=$(dc-http -s -m=HEAD https://WHATEVERTHISISITWILLFAIL)
  exit=$?
  dc-tools::assert::equal "http dns failure exit code" "$exit" "$ERROR_NETWORK"
  dc-tools::assert::equal "$result" ""
}

testHTTPNoServer(){
  # No response at that address
  result=$(dc-http -s -m=HEAD https://locahost:12345)
  exit=$?
  dc-tools::assert::equal "$exit" "$ERROR_NETWORK"
  dc-tools::assert::equal "$result" ""
}

testHTTPUnexpectedTLS(){
  # HTTP on HTTPS
  result=$(dc-http -s -m=HEAD https://www.google.com:80)
  exit=$?
  dc-tools::assert::equal "$exit" "$ERROR_NETWORK"
  dc-tools::assert::equal "$result" ""
}

testHTTPUnexpectedNoTLS(){
  # HTTPS on HTTP
  result=$(dc-http -s -m=HEAD http://www.google.com:443)
  exit=$?
  dc-tools::assert::equal "$exit" "$ERROR_NETWORK"
  dc-tools::assert::equal "$result" ""
}

testHTTPRedirect(){
  # Redirect
  result=$(dc-http -s -m=HEAD https://google.com)
  exit=$?
  status="$(printf "%s" "$result" | jq -r -c .status)"
  redirected="$(printf "%s" "$result" | jq -r -c .redirected)"
  body="$(printf "%s" "$result" | jq -r -c .body)"
  headers="$(printf "%s" "$result" | jq -r -c .headers)"
  server="$(printf "%s" "$headers" | jq -r -c .SERVER)"
  dc-tools::assert::equal "$exit" "0"
  dc-tools::assert::equal "$status" "200"
  dc-tools::assert::equal "$redirected" "https://www.google.com/"
  dc-tools::assert::equal "$body" ""
  dc-tools::assert::equal "$server" "gws"
}

testHTTPValidHEAD(){
  # Valid HEAD request
  result=$(dc-http -s -m=HEAD https://www.google.com)
  exit=$?
  status="$(printf "%s" "$result" | jq -r -c .status)"
  redirected="$(printf "%s" "$result" | jq -r -c .redirected)"
  body="$(printf "%s" "$result" | jq -r -c .body)"
  headers="$(printf "%s" "$result" | jq -r -c .headers)"
  dc-tools::assert::equal "$exit" "0"
  dc-tools::assert::equal "$status" "200"
  dc-tools::assert::equal "$redirected" ""
  dc-tools::assert::equal "$body" ""
}

testHTTPValidGET(){
  # Valid GET request
  result=$(dc-http -s -m=GET https://registry-1.docker.io/v2)
  exit=$?
  status="$(printf "%s" "$result" | jq -r -c .status)"
  redirected="$(printf "%s" "$result" | jq -r -c .redirected)"
  body="$(printf "%s" "$result" | jq -r -c .body | dc::wrapped::base64d)"
  headers="$(printf "%s" "$result" | jq -r -c .headers)"
  dc-tools::assert::equal "$exit" "0"
  dc-tools::assert::equal "$status" "401"
  dc-tools::assert::equal "$redirected" "/v2/"
  dc-tools::assert::equal "$body" '{"errors":[{"code":"UNAUTHORIZED","message":"authentication required","detail":null}]}'
}
