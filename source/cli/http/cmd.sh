#!/usr/bin/env bash

true
# shellcheck disable=SC2034
readonly CLI_DESC="just curl, in a nicer, json-way"
# shellcheck disable=SC2034
readonly CLI_EXAMPLES="Simple get request, get the Date reponse header
> dc-http -s localhost:5000 | jq -r .headers.DATE

Echo the body of the response of a complex PUT request
> echo 'something' | dc-http -s --method=PUT --file=/dev/stdin http://localhost:5000 'User-Agent: pouic-pouic/alpha-omega' | jq -rc .body | base64 -D

To submit a file:
> dc-http -s --method=PUT --file=some_file_somewhere http://server

To submit something you already have around you can either:
> printf '%s' 'some payload' | dc-http -s --method=PUT --file=/dev/stdin http://server

Or:
> dc-http -s --method=PUT --file=/dev/stdin http://server < <(printf '%s' 'some payload')
"

# Initialize
dc::commander::initialize
dc::commander::declare::flag "method" "^[a-zA-Z]+$" "http method (default to GET)" optional "m"
dc::commander::declare::flag "file" ".+" "file to use as payload" optional "f"
dc::commander::declare::arg 1 ".+" "url" "url to query"
# dc::commander::declare::arg 2 "" "method" "http method (default to GET)" optional
# dc::commander::declare::arg 2 "" "payload" "file payload to post" optional
dc::commander::declare::arg 2 "^$" "[...headers]" "additional headers to be passed" optional
dc::commander::boot

# Requirements
dc::require jq || exit

# URL METHOD PAYLOAD HEADERS
opts=( "$DC_PARGV_1" "${DC_ARGV_METHOD:-$DC_ARGV_M}" "${DC_ARGV_FILE:-$DC_ARGV_F}" )
x=2
e="DC_PARGE_$x"
while [ "${!e}" ]; do
  n="DC_PARGV_$x"
  opts+=("${!n}")
  x=$(( x + 1 ))
  e="DC_PARGE_$x"
done

body=$(dc::http::request "${opts[@]}")

if [ ! "$DC_HTTP_STATUS" ]; then
  dc::logger::error "Network issue... Recommended: check your pooch whereabouts. Now, check these chewed-up network cables."
  exit "$ERROR_NETWORK"
fi

for i in "${DC_HTTP_HEADERS[@]}"; do
  [ "$heads" ] && heads="$heads,"
  name="DC_HTTP_HEADER_$i"
  value=$(printf "%s" "${!name}" | tr '"' "'")
  heads="$heads\"$i\": \"$value\""
done

output=$( printf "%s" "{$heads}" | jq --arg body "$(base64 "$body")" --arg status "$DC_HTTP_STATUS" --arg location "${DC_HTTP_REDIRECTED}" -r '{
  status: $status,
  redirected: $location,
  headers: .,
  body: $body
}
')

dc::output::json "$output"
