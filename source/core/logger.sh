#!/usr/bin/env bash
##########################################################################
# Logger
# ------
# Logger infrastructure
##########################################################################

dc::internal::logger::log(){
  local prefix="$1"
  shift

  local level="DC_LOGGER_$prefix"
  local style="DC_LOGGER_STYLE_${prefix}[@]"
  local i

  [ "$_DC_INTERNAL_LOGGER_LEVEL" -lt "${!level}" ] && return

  [ ! "$TERM" ] || [ ! -t 2 ] || >&2 tput "${!style}"
  for i in "$@"; do
    >&2 printf "[%s] [%s] %s\n" "$(date)" "$prefix" "$i"
  done
  [ ! "$TERM" ] || [ ! -t 2 ] || >&2 tput op
}

dc::internal::logger::setlevel() {
  local level="$1"

  # Level is an int between ERROR and DEBUG, or fallback to INFO
  dc::argument::check level "$DC_TYPE_INTEGER" && [ "$level" -ge "$DC_LOGGER_ERROR" ] && [ "$level" -le "$DC_LOGGER_DEBUG" ] || level="$DC_LOGGER_INFO"

  _DC_INTERNAL_LOGGER_LEVEL="$level"
  [ "$level" != "$DC_LOGGER_DEBUG" ] ||
    dc::internal::logger::log "WARNING" "[Logger] YOU ARE LOGGING AT THE DEBUG LEVEL. This is NOT recommended for production use, and WILL LIKELY LEAK sensitive information to stderr."
}

dc::configure::logger::setlevel::debug(){
  dc::internal::logger::setlevel "$DC_LOGGER_DEBUG"
}

dc::configure::logger::setlevel::info(){
  dc::internal::logger::setlevel "$DC_LOGGER_INFO"
}

dc::configure::logger::setlevel::warning(){
  dc::internal::logger::setlevel "$DC_LOGGER_WARNING"
}

dc::configure::logger::setlevel::error(){
  dc::internal::logger::setlevel "$DC_LOGGER_ERROR"
}

dc::configure::logger::mute() {
  _DC_INTERNAL_LOGGER_LEVEL=0
}

#####################################
# Public API
#####################################

dc::logger::debug(){
  dc::internal::logger::log "DEBUG" "$@"
}

dc::logger::info(){
  dc::internal::logger::log "INFO" "$@"
}

dc::logger::warning(){
  dc::internal::logger::log "WARNING" "$@"
}

dc::logger::error(){
  dc::internal::logger::log "ERROR" "$@"
}
