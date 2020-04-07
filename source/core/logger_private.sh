#!/usr/bin/env bash
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

  [ "$_DC_PRIVATE_LOGGER_LEVEL" -lt "${!level}" ] && return

  [ ! "$TERM" ] || [ ! -t 2 ] || >&2 dc::internal::wrap tput "${!style}" 2>/dev/null || true
  for i in "$@"; do
    >&2 printf "[%s] [%s] %s\n" "$(dc::internal::wrap date 2>/dev/null || true)" "$prefix" "$i"
  done
  [ ! "$TERM" ] || [ ! -t 2 ] || >&2 dc::internal::wrap tput op 2>/dev/null || true
}

