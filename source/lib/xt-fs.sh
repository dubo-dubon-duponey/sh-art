#!/usr/bin/env bash

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
