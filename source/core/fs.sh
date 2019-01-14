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
    dc::logger::error "You need to specify a valid file that you have access to (you provided: $1)"
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
    dc::logger::error "You need to specify a valid directory that you have access to (you provided: $1)"
    exit "$ERROR_FILESYSTEM"
  fi

}
