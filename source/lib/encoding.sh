#!/usr/bin/env bash

# Convert all files to utf8
dc::encoding::toutf8(){
  local file="${1:-/dev/stdin}"
  local source

  source="$(dc::wrapped::uchardet "$file")"
  if [ "$source" == "unknown" ]; then
    dc::error::detail::set "$file"
    return "$ERROR_ENCODING_UNKNOWN"
  fi

  dc::wrapped::iconv -f "$source" -t utf-8 "$file" \
    || { dc::logger::error "Failed converting file $file from $source to utf8" && return "$ERROR_ENCODING_CONVERSION_FAIL"; }
}

# A helper to encode uri fragments
dc::encoding::uriencode() {
  local s
  s="${*//'%'/%25}"
  s="${s//' '/%20}"
  s="${s//'"'/%22}"
  s="${s//'#'/%23}"
  s="${s//'$'/%24}"
  s="${s//'&'/%26}"
  s="${s//'+'/%2B}"
  s="${s//','/%2C}"
  s="${s//'/'/%2F}"
  s="${s//':'/%3A}"
  s="${s//';'/%3B}"
  s="${s//'='/%3D}"
  s="${s//'?'/%3F}"
  s="${s//'@'/%40}"
  s="${s//'['/%5B}"
  s="${s//']'/%5D}"
  printf %s "$s"
}
