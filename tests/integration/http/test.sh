#!/usr/bin/env bash


#python -m SimpleHTTPServer 12345

# DNS resolution failure
result=$(dc-http -s https://WHATEVERTHISISITWILLFAIL  "HEAD")
exit=$?
dc-tools::assert::equal "$exit" "$ERROR_NETWORK" "http dns failure exit code"
dc-tools::assert::equal "$result" ""

# No response at that address
result=$(dc-http -s https://locahost:12345 "HEAD")
exit=$?
dc-tools::assert::equal "$exit" "$ERROR_NETWORK"
dc-tools::assert::equal "$result" ""

# HTTP on HTTPS
result=$(dc-http -s https://www.google.com:80 "HEAD")
exit=$?
dc-tools::assert::equal "$exit" "$ERROR_NETWORK"
dc-tools::assert::equal "$result" ""

# HTTPS on HTTP
result=$(dc-http -s http://www.google.com:443 "HEAD")
exit=$?
dc-tools::assert::equal "$exit" "$ERROR_NETWORK"
dc-tools::assert::equal "$result" ""

# Redirect
result=$(dc-http -s https://google.com "HEAD")
exit=$?
status="$(printf "%s" "$result" | jq -rc .status)"
redirected="$(printf "%s" "$result" | jq -rc .redirected)"
body="$(printf "%s" "$result" | jq -rc .body)"
headers="$(printf "%s" "$result" | jq -rc .headers)"
server="$(printf "%s" "$headers" | jq -rc .SERVER)"
dc-tools::assert::equal "$exit" "0"
dc-tools::assert::equal "$status" "200"
dc-tools::assert::equal "$redirected" "https://www.google.com/"
dc-tools::assert::equal "$body" ""
dc-tools::assert::equal "$server" "gws"

# Valid HEAD request
result=$(dc-http -s https://www.google.com "HEAD")
exit=$?
status="$(printf "%s" "$result" | jq -rc .status)"
redirected="$(printf "%s" "$result" | jq -rc .redirected)"
body="$(printf "%s" "$result" | jq -rc .body)"
headers="$(printf "%s" "$result" | jq -rc .headers)"
dc-tools::assert::equal "$exit" "0"
dc-tools::assert::equal "$status" "200"
dc-tools::assert::equal "$redirected" ""
dc-tools::assert::equal "$body" ""

# Valid GET request
result=$(dc-http -s https://registry-1.docker.io/v2 "GET")
exit=$?
status="$(printf "%s" "$result" | jq -rc .status)"
redirected="$(printf "%s" "$result" | jq -rc .redirected)"
body="$(printf "%s" "$result" | jq -rc .body | base64 -D)"
headers="$(printf "%s" "$result" | jq -rc .headers)"
dc-tools::assert::equal "$exit" "0"
dc-tools::assert::equal "$status" "401"
dc-tools::assert::equal "$redirected" "/v2/"
dc-tools::assert::equal "$body" '{"errors":[{"code":"UNAUTHORIZED","message":"authentication required","detail":null}]}'
