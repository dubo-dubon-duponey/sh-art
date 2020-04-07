#!/usr/bin/env bash

dc::wrapped::uchardet(){
  dc::require uchardet || return

  uchardet "$@" 2>/dev/null \
    || { dc::error::detail::set "uchardet" && return "$ERROR_BINARY_UNKNOWN_ERROR"; }
}

dc::wrapped::iconv(){
  dc::require iconv || return

  iconv "$@" 2>/dev/null \
    || { dc::error::detail::set "iconv" && return "$ERROR_BINARY_UNKNOWN_ERROR"; }
}

# Convert all files to utf8
dc::encoding::toutf8(){
  local fd="${1:-/dev/stdin}"
  local source

  source="$(dc::wrapped::uchardet "$fd")"
  if [ "$source" == "unknown" ]; then
    dc::error::detail::set "$fd"
    return "$ERROR_ENCODING_UNKNOWN"
  fi

  dc::wrapped::iconv -f "$source" -t utf-8 "$fd" \
    || {
      dc::error::detail::set "$fd ($source->utf8)"
      return "$ERROR_ENCODING_CONVERSION_FAIL"
    }
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
