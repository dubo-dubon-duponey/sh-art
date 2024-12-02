#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

# shellcheck disable=SC2034
readonly CLI_DESC="just curl, in a nicer, json-way"
# shellcheck disable=SC2034
readonly CLI_EXAMPLES="Simple get request, get the Date reponse header
> dc-http -s localhost:5000 | jq -r .headers.DATE

Echo the body of the response of a complex PUT request
> echo 'something' | dc-http -s --method=PUT --file=/dev/stdin http://localhost:5000 'User-Agent: pouic-pouic/alpha-omega' | jq -r .body | base64 -D

To submit a file:
> dc-http -s --method=PUT --file=some_file_somewhere http://server

To submit something you already have around you can either:
> printf '%s' 'some payload' | dc-http -s --method=PUT --file=/dev/stdin http://server

Or:
> dc-http -s --method=PUT --file=/dev/stdin http://server < <(printf '%s' 'some payload')
"

dc::commander::initialize
dc::commander::declare::flag "method" "^[a-zA-Z]+$" "http method (default to GET)" optional "m"
dc::commander::declare::flag "file" "$DC_TYPE_STRING" "file to use as payload" optional "f"
dc::commander::declare::arg 1 "$DC_TYPE_STRING" "url" "url to query"
# dc::commander::declare::arg 2 "" "method" "http method (default to GET)" optional
# dc::commander::declare::arg 2 "" "payload" "file payload to post" optional
dc::commander::declare::arg 2 "" "[...headers]" "additional headers to be passed" optional
dc::commander::boot

# Requirements
dc::require jq

# URL METHOD PAYLOAD HEADERS
opts=( "$DC_ARG_1" "${DC_ARG_METHOD:-$DC_ARG_M}" "${DC_ARG_FILE:-${DC_ARG_F:-}}" )
x=2

while dc::args::exist "$x"; do
  n="DC_ARG_$x"
  opts+=("${!n}")
  x=$(( x + 1 ))
done

tmpfile="$(dc::fs::mktemp "dc-http")"

if ! dc::http::request "${opts[@]}" > "$tmpfile"; then
  dc::logger::error "Network issue... you may want to check these chewed-up network cables."
  exit "$ERROR_NETWORK"
fi
if [ ! "$DC_HTTP_STATUS" ]; then
  dc::logger::error "Server issue... Response was $DC_HTTP_STATUS"
  exit "$ERROR_NETWORK"
fi

heads=""
for i in "${DC_HTTP_HEADERS[@]}"; do
  [ "$heads" ] && heads="$heads,"
  name="DC_HTTP_HEADER_$i"
  value=$(printf "%s" "${!name}" | tr '"' "'")
  heads="$heads\"$i\": \"$value\""
done

output=$( printf "%s" "{$heads}" | jq --arg body "$(base64 -i "$tmpfile")" --arg status "$DC_HTTP_STATUS" --arg location "${DC_HTTP_REDIRECTED}" -r '{
  status: $status,
  redirected: $location,
  headers: .,
  body: $body
}')

dc::output::json "$output"
