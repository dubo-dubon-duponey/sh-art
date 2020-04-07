#!/usr/bin/env bash
##########################################################################
# Private helpers
# ------
# Do NOT use them unless you know what you do
# Will change without notification
##########################################################################

_dc::private::has::grep(){
  if ! command -v grep > /dev/null && [ ! -f /usr/bin/grep ] ; then
    >&2 printf "[%s] %s\n" "$(date 2>/dev/null || true)" "You need grep for this to work"
    return 144
  fi
}

# XXX move this elsewhere? Or fail here?
_dc::private::has::grep || exit
