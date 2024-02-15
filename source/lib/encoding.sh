#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

dc::wrapped::uchardet(){
  dc::require uchardet || return

  uchardet "$@" 2>/dev/null \
    || {
      dc::error::throw BINARY_UNKNOWN_ERROR "uchardet"
      return
    }
}

dc::wrapped::iconv(){
  dc::require iconv || return

  iconv "$@" 2>/dev/null \
    || {
      dc::error::throw BINARY_UNKNOWN_ERROR "iconv"
      return
    }
}

# Convert all files to utf8
dc::encoding::toutf8(){
  local fd="${1:-/dev/stdin}"
  local source

  source="$(dc::wrapped::uchardet "$fd")"
  if [ "$source" == "unknown" ]; then
    dc::error::throw ENCODING_UNKNOWN "$fd"
    return
  fi

  dc::wrapped::iconv -f "$source" -t utf-8 "$fd" \
    || {
      dc::error::throw ENCODING_CONVERSION_FAIL "$fd ($source->utf8)"
      return
    }
}

