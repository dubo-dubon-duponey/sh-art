#!/usr/bin/env bash

readonly CLI_DESC="just curl, in a nicer, json-way"

# Initialize
dc::commander::initialize
dc::commander::declare::flag "method" "^[a-zA-Z]+$" optional "http method (default to GET)" "m"
dc::commander::declare::flag "file" ".+" optional "file to use as payload" "f"
dc::commander::declare::arg 1 ".+" "" "url" "url to query"
# dc::commander::declare::arg 2 "" optional "method" "http method (default to GET)"
# dc::commander::declare::arg 2 "" optional "payload" "file payload to post"
dc::commander::declare::arg 2 "" optional "[...headers]" "additional headers to be passed"
dc::commander::boot

# Requirements
dc::require jq

# XXX "$(<some_file)" to pass stdin?
# URL METHOD PAYLOAD HEADERS
# XXX implement --method and stdin payload
opts=( "$DC_PARGV_1" "${DC_ARGV_METHOD:-$DC_ARGV_M}" "${DC_ARGV_FILE:-$DC_ARGV_F}" )
x=2
e="DC_PARGE_$x"
while [ "${!e}" ]; do
  n="DC_PARGV_$x"
  opts[${#opts[@]}]="${!n}"
  x=$(( x + 1 ))
  e="DC_PARGE_$x"
done

dc::http::request "${opts[@]}"

if [ ! "$DC_HTTP_STATUS" ]; then
  dc::logger::error "Network issue... Recommended: check your pooch whereabouts. Now, check these chewed-up network cables."
  exit "$ERROR_NETWORK"
fi

for i in $DC_HTTP_HEADERS; do
  [ "$heads" ] && heads="$heads,"
  name="DC_HTTP_HEADER_$i"
  value=$(printf "%s" "${!name}" | tr '"' "'")
  heads="$heads\"$i\": \"$value\""
done

output=$( printf "%s" "{$heads}" | jq --arg body "$(base64 "$DC_HTTP_BODY")" --arg status "$DC_HTTP_STATUS" --arg location "${DC_HTTP_REDIRECTED}" -r '{
  status: $status,
  redirected: $location,
  headers: .,
  body: $body
}
')

dc::output::json "$output"
