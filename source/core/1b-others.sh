#!/usr/bin/env bash
set -o pipefail
# XXX testing framework still chokes on -e - builder also broken by -u right now
# set -eu

##########################################################################
# Entrypoint: grep and other essential binaries
# ------
# Grep is central to many validation mechanism. We simply cannot function without it for now.
##########################################################################

dc::internal::has::grep(){
  if ! command -v grep > /dev/null; then
    >&2 printf "[%s] %s\n" "$(date 2>/dev/null || true)" "You need grep for this to work"
    return 144
  fi
}

dc::internal::has::date(){
  if ! command -v date > /dev/null; then
    >&2 printf "[] %s\n" "No \"date\" binary on your system. Logs will have no timestamp."
    return 144
  fi
}

# XXX move this elsewhere?
dc::internal::has::grep || exit

# Not having the date binary is survivable
dc::internal::has::date || true
