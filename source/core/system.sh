#!/usr/bin/env bash

##########################################################################
# For internal use only
# ------
# This is meant to provide portable code for system operation calling on
# binaries which implementations vary too significantly.
##########################################################################

portable::mktemp(){
  mktemp -q "${TMPDIR:-/tmp}/$1.XXXXXX" 2>/dev/null || mktemp -q
}

portable::base64d(){
  case "$(uname)" in
    Darwin)
      base64 -D
    ;;
    *)
      base64 -d
    ;;
  esac
}
