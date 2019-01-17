#!/usr/bin/env bash

readonly CLI_DESC="like curl, in a nicer json-way"

# Initialize
dc::commander::initialize
dc::commander::declare::arg 1 ".+" "" "url" "url to query"
dc::commander::declare::arg 2 ".+" "optional" "method" "http method (default to GET)"
dc::commander::declare::arg 3 ".+" "optional" "payload" "payload to post"
dc::commander::declare::arg 4 ".+" "optional" "[...headers]" "additional headers to be passed"
# Start commander
dc::commander::boot

# Requirements
dc::require jq

# XXX "$(<some_file)" to pass stdin?
# URL METHOD PAYLOAD HEADERS
# XXX implement --method and stdin payload
dc::http::request "$DC_PARGV_1" "$DC_PARGV_2" "$DC_PARGV_3" "$DC_PARGV_4"

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
