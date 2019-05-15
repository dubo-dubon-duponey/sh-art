#!/usr/bin/env bash

# Convert all files to utf8
encoding::toutf8(){
  local file="$1"
  local result
  local source
  source="$(uchardet "$file")"
  if [ "$source" == "unknown" ]; then
    dc::logger::error "Could not guess encoding for $file"
    exit "$ERROR_FAILED"
  fi
  if ! result="$(iconv -f "$source" -t utf-8 "$file")"; then
    dc::logger::error "Failed converting file $file from $source to utf8"
    exit "$ERROR_FAILED"
  fi
  dc::logger::debug "Successfully converted encoding for $file (initially $source)"
  printf "%s\n" "$result"
}
