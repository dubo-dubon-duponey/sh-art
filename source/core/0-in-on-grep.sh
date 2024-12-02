#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

##########################################################################
# Entrypoint: grep
##########################################################################

_dc::private::has::grep(){
  if ! command -v grep > /dev/null && [ ! -f /usr/bin/grep ] ; then
    >&2 printf "[%s] %s\n" "$(date 2>/dev/null || true)" "You need grep for this to work"
    return 144
  fi
}

_dc::private::has::grep || exit
