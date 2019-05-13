#!/usr/bin/env bash

readonly CLI_VERSION="1.0.0"
readonly CLI_LICENSE="MIT License"
readonly CLI_DESC="query the AcoustId web-service"

dc::commander::initialize
# recordings, recordingids, releases, releaseids, releasegroups, releasegroupids, tracks, compress, usermeta, sources
dc::commander::declare::flag meta ".*" "What to include in the return value (space separated list of: )" optional
dc::commander::declare::flag duration "^[0-9.]+$" "Duration, if in fingerprint mode" optional
dc::commander::declare::arg 1 ".+" "data" "either the fingerprint of a track (must come along with a --duration=XXX flag, or a trackid)"
# Start commander
dc::commander::boot

# Require jq
dc::require jq

readonly APPKEY="NJWSshfioI"
readonly UA="DuboAcoustIdBashCLI/$CLI_VERSION"

acoustid::lookup::fingerprint(){
  local duration="$1"
  local fingerprint="$2"
  local meta="$3"
  dc::http::request "https://api.acoustid.org/v2/lookup?format=json&client=$APPKEY&duration=$duration&fingerprint=$fingerprint&meta=compress $meta" "GET" "" "User-Agent: $UA"
}

acoustid::lookup::trackid(){
  local trackid="$1"
  local meta="$2"
  dc::http::request "https://api.acoustid.org/v2/lookup?format=json&client=$APPKEY&trackid=$trackid&meta=compress $meta" "GET" "" "User-Agent: $UA"
}

# If there is a duration, round it to the second
duration=
if [ "$DC_ARGV_DURATION" ]; then
  duration=$(printf "%.0f" "$DC_ARGV_DURATION")
fi

# Do fingerprint or id mode depending on whether there is a duration specified
if [ "$duration" ]; then
  echo "wanna do lookup"
  acoustid::lookup::fingerprint "$duration" "$DC_PARGV_1" "$DC_ARGV_META"
else
  acoustid::lookup::trackid "$DC_PARGV_1" "$DC_ARGV_META"
fi

# Spit it out
cat "$DC_HTTP_BODY" | jq .
