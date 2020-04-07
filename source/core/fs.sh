#!/usr/bin/env bash
##########################################################################
# FS
# ------
# Filesystem helpers
##########################################################################

dc::fs::rm(){
  local path="${1:-}"

  dc::argument::check path "$DC_TYPE_STRING" || return

  rm -f "$path" 2>/dev/null \
    || {
      dc::error::detail::set "$path"
      return "$ERROR_FILESYSTEM"
    }
}

dc::fs::mktemp(){
  local prefix="${1:-dbdbdp}"

  dc::argument::check prefix "$DC_TYPE_STRING" || return

  mktemp -q "${TMPDIR:-/tmp}/$prefix.XXXXXX" 2>/dev/null || mktemp -q || return "$ERROR_FILESYSTEM"
}

dc::fs::isdir(){
  local path="${1:-}"
  local writable="${2:-}"
  local createIfMissing="${3:-}"

  dc::argument::check path "$DC_TYPE_STRING" || return

  [ ! "$createIfMissing" ] || mkdir -p "$path" 2>/dev/null || return "$ERROR_FILESYSTEM"
  if [ ! -d "$path" ] || [ ! -r "$path" ] || { [ "$writable" ] && [ ! -w "$path" ]; }  ; then
    dc::error::detail::set "$path"
    return "$ERROR_FILESYSTEM"
  fi
}

dc::fs::isfile(){
  local path="${1:-}"
  local writable="${2:-}"
  local createIfMissing="${3:-}"

  dc::argument::check path "$DC_TYPE_STRING" || return

  [ ! "$createIfMissing" ] || touch "$path" || return "$ERROR_FILESYSTEM"
  if [ ! -f "$path" ] || [ ! -r "$path" ] || { [ "$writable" ] && [ ! -w "$path" ]; }  ; then
    dc::error::detail::set "$path"
    return "$ERROR_FILESYSTEM"
  fi
}
