#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

##########################################################################
# Logger
# ------
# Logger infrastructure
##########################################################################

_DC_PRIVATE_LOGGER_LEVEL=2

_dc::private::logger::log(){
  local prefix="$1"
  shift

  local level="DC_LOGGER_$prefix"
  local style="DC_LOGGER_STYLE_${prefix}[@]"
  local i

  [ "$_DC_PRIVATE_LOGGER_LEVEL" -ge "${!level}" ] || return 0

  # If you wonder about why that crazy shit: https://stackoverflow.com/questions/12674783/bash-double-process-substitution-gives-bad-file-descriptor
  exec 3>&2
  [ ! "$TERM" ] || [ ! -t 2 ] || >&2 dc::internal::securewrap tput "${!style}" 2>/dev/null || true
  for i in "$@"; do
    >&2 printf "[%s] [%s] %s\n" "$(date 2>/dev/null || true)" "$prefix" "$i"
  done
  [ ! "$TERM" ] || [ ! -t 2 ] || >&2 dc::internal::securewrap tput op 2>/dev/null || true
  exec 3>&-
}
