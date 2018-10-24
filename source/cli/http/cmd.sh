#!/usr/bin/env bash

readonly CLI_VERSION="0.0.1"
readonly CLI_LICENSE="MIT License"
readonly CLI_DESC="like curl, in a nicer json-way"
readonly CLI_USAGE="[-s] [--insecure] url [method] [payload] [...headers]"

# Initialize
dc::commander::initialize

# Requirements
dc::require jq

# Start commander
dc::commander::boot

# XXX "$(<some_file)" to pass stdin?
# URL METHOD PAYLOAD HEADERS
# XXX implement --method and stdin payload
dc::http::request "$@"

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
