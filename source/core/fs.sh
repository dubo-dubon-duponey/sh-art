#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

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
      dc::error::throw FILESYSTEM "$path" || return
    }
}

dc::fs::mktemp(){
  local prefix="${1:-dbdbdp}"

  dc::argument::check prefix "$DC_TYPE_STRING" || return

  mktemp -q "${TMPDIR:-/tmp}/$prefix.XXXXXX" 2>/dev/null || mktemp -q || dc::error::throw FILESYSTEM "$prefix" || return
}

dc::fs::isdir(){
  local path="${1:-}"
  local writable="${2:-}"
  local createIfMissing="${3:-}"

  dc::argument::check path "$DC_TYPE_STRING" || return

  [ ! "$createIfMissing" ] || mkdir -p "$path" 2>/dev/null || dc::error::throw FILESYSTEM || return
  if [ ! -d "$path" ] || [ ! -r "$path" ] || { [ "$writable" ] && [ ! -w "$path" ]; }  ; then
    dc::error::throw FILESYSTEM "$path" || return
  fi
}

dc::fs::isfile(){
  local path="${1:-}"
  local writable="${2:-}"
  local createIfMissing="${3:-}"

  dc::argument::check path "$DC_TYPE_STRING" || return

  [ ! "$createIfMissing" ] || touch "$path" || dc::error::throw FILESYSTEM || return
  if [ ! -f "$path" ] || [ ! -r "$path" ] || { [ "$writable" ] && [ ! -w "$path" ]; }  ; then
    dc::error::throw FILESYSTEM "$path" || return
  fi
}
