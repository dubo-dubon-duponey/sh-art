#!/usr/bin/env bash

readonly CLI_VERSION="1.0.0"
readonly CLI_LICENSE="MIT License"
readonly CLI_DESC="fingerprint local music files"

dc::commander::initialize
# recordings, recordingids, releases, releaseids, releasegroups, releasegroupids, tracks, compress, usermeta, sources
dc::commander::declare::arg 1 ".+" "file" "music file to analyze"
# Start commander
dc::commander::boot

# Require jq
dc::require jq
dc::require fpcalc

# Ensure the file exist and is readable
dc::fs::isfile "$DC_PARGV_1"

acoustid::analyze(){
  local file="$1"
  if ! fpcalc -json "$file" 2>/dev/null; then
    dc::logger::error "Failed to fingerprint file $1. Is this a valid music file?"
    exit "$ERROR_FAILED"
  fi
}

acoustid::analyze "$DC_PARGV_1"

# Will output: {duration: X.Y, fingerprint: FOO}
