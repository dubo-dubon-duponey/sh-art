#!/usr/bin/env bash
##########################################################################
# FS
# ------
# Filesystem helpers
##########################################################################

dc::fs::rm(){
  local f="$1"

  rm -f "$f" 2>/dev/null \
    || {
      dc::error::detail::set "$f"
      return "$ERROR_FILESYSTEM"
    }
}

dc::fs::mktemp(){
  mktemp -q "${TMPDIR:-/tmp}/$1.XXXXXX" 2>/dev/null || mktemp -q || return "$ERROR_FILESYSTEM"
}

dc::fs::isdir(){
  local path="$1"
  local writable="$2"
  local createIfMissing="$3"

  [ ! "$createIfMissing" ] || mkdir -p "$path" 2>/dev/null || return "$ERROR_FILESYSTEM"
  if [ ! -d "$path" ] || [ ! -r "$path" ] || { [ "$writable" ] && [ ! -w "$path" ]; }  ; then
    dc::error::detail::set "$path"
    return "$ERROR_FILESYSTEM"
  fi
}

dc::fs::isfile(){
  local path="$1"
  local writable=$2
  local createIfMissing=$3
  [ ! "$createIfMissing" ] || touch "$path"
  if [ ! -f "$path" ] || [ ! -r "$path" ] || { [ "$writable" ] && [ ! -w "$path" ]; }  ; then
    dc::error::detail::set "$path"
    exit "$ERROR_FILESYSTEM"
  fi
}
