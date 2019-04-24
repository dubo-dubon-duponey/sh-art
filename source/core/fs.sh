#!/usr/bin/env bash
##########################################################################
# FS
# ------
# Filesystem verification and manipulation helpers
##########################################################################

dc::fs::isfile(){
  local writable=$2
  local createIfMissing=$3
  if [ "$createIfMissing" ]; then
    touch "$1"
  fi
  if [ ! -f "$1" ] || [ ! -r "$1" ] || { [ "$writable" ] && [ ! -w "$1" ]; }  ; then
    dc::logger::error "$1 is not a valid file or you do not have the appropriate permissions"
    exit "$ERROR_FILESYSTEM"
  fi
}

dc::fs::isdir(){
  local writable=$2
  local createIfMissing=$3
  if [ "$createIfMissing" ]; then
    mkdir -p "$1"
  fi
  if [ ! -d "$1" ] || [ ! -r "$1" ] || { [ "$writable" ] && [ ! -w "$1" ]; }  ; then
    dc::logger::error "$1 is not a valid directory or you do not have the appropriate permissions"
    exit "$ERROR_FILESYSTEM"
  fi

}
