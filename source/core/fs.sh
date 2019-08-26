#!/usr/bin/env bash
##########################################################################
# FS
# ------
# Filesystem verification and manipulation helpers
##########################################################################

dc::fs::rm(){
  local f="$1"
  rm -f "$f" 2>/dev/null \
    || { dc::error::detail::set "$f" && return "$ERROR_FILESYSTEM"; }
}

dc::fs::mktemp(){
  mktemp -q "${TMPDIR:-/tmp}/$1.XXXXXX" 2>/dev/null || mktemp -q || return "$ERROR_FILESYSTEM"
}

dc::fs::isdir(){
  local writable=$2
  local createIfMissing=$3
  [ ! "$createIfMissing" ] || mkdir -p "$1" 2>/dev/null || return "$ERROR_FILESYSTEM"
  if [ ! -d "$1" ] || [ ! -r "$1" ] || { [ "$writable" ] && [ ! -w "$1" ]; }  ; then
    dc::error::detail::set "$1"
    return "$ERROR_FILESYSTEM"
  fi
}
