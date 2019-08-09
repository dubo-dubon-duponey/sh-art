#!/usr/bin/env bash

dc::crypto::shasum::verify(){
  dc::require shasum
  local file="$1"
  local expected="$2"
  digest=$(shasum -a 256 "$file" 2>/dev/null)
  digest="sha256:${digest%% *}"
  if [ "$digest" != "$expected" ]; then
    dc::logger::error "Verification failed for object $file (expected: $expected - was: $digest)"
    dc::logger::debug "File was $file"
    exit "$ERROR_SHASUM_FAILED"
  fi
}

dc::crypto::shasum::compute(){
  dc::require shasum
  local file="$1"
  local type="${2:-256}"
  local raw="$3"
  [ "$raw" ] && raw="" || raw="sha${type}:"
  digest=$(shasum -a "$type" "$file" 2>/dev/null)
  printf "%s" "$raw${digest%% *}"
}
