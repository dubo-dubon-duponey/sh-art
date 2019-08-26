#!/usr/bin/env bash
##########################################################################
# Logger
# ------
# Logger
##########################################################################

#####################################
# Configuration hooks
#####################################

dc::configure::logger::setlevel() {
  local level="$1"
  dc::argument::check level "$DC_TYPE_INTEGER" && [ "$level" -ge "$DC_LOGGER_ERROR" ] && [ "$level" -le "$DC_LOGGER_DEBUG" ] || level="$DC_LOGGER_INFO"
  _DC_INTERNAL_LOGGER_LEVEL="$level"
  if [ "$_DC_INTERNAL_LOGGER_LEVEL" == "$DC_LOGGER_DEBUG" ]; then
    dc::logger::warning "[Logger] YOU ARE LOGGING AT THE DEBUG LEVEL. This is NOT recommended for production use, and WILL LIKELY LEAK sensitive information to stderr."
  fi
}

dc::configure::logger::setlevel::debug(){
  # XXX test this: set -x
  # Too noisy, not useful
  dc::configure::logger::setlevel "$DC_LOGGER_DEBUG"
}

dc::configure::logger::setlevel::info(){
  dc::configure::logger::setlevel "$DC_LOGGER_INFO"
}

dc::configure::logger::setlevel::warning(){
  dc::configure::logger::setlevel "$DC_LOGGER_WARNING"
}

dc::configure::logger::setlevel::error(){
  dc::configure::logger::setlevel "$DC_LOGGER_ERROR"
}

dc::configure::logger::mute() {
  _DC_INTERNAL_LOGGER_LEVEL=0
}

#####################################
# Public API
#####################################

dc::logger::debug(){
  if [ "$_DC_INTERNAL_LOGGER_LEVEL" -ge "$DC_LOGGER_DEBUG" ]; then
    [ "$TERM" ] && [ -t 2 ] && >&2 tput "${DC_LOGGER_STYLE_DEBUG[@]}"
    local i
    for i in "$@"; do
      dc::internal::logger::stamp "[DEBUG]" "$i"
    done
    [ "$TERM" ] && [ -t 2 ] && >&2 tput op
  fi
}

dc::logger::info(){
  if [ "$_DC_INTERNAL_LOGGER_LEVEL" -ge "$DC_LOGGER_INFO" ]; then
    [ "$TERM" ] && [ -t 2 ] && >&2 tput "${DC_LOGGER_STYLE_INFO[@]}"
    local i
    for i in "$@"; do
      dc::internal::logger::stamp "[INFO]" "$i"
    done
    [ "$TERM" ] && [ -t 2 ] && >&2 tput op
  fi
}

dc::logger::warning(){
  if [ "$_DC_INTERNAL_LOGGER_LEVEL" -ge "$DC_LOGGER_WARNING" ]; then
    [ "$TERM" ] && [ -t 2 ] && >&2 tput "${DC_LOGGER_STYLE_WARNING[@]}"
    local i
    for i in "$@"; do
      dc::internal::logger::stamp "[WARNING]" "$i"
    done
    [ "$TERM" ] && [ -t 2 ] && >&2 tput op
  fi
}

dc::logger::error(){
  if [ "$_DC_INTERNAL_LOGGER_LEVEL" -ge "$DC_LOGGER_ERROR" ]; then
    [ "$TERM" ] && [ -t 2 ] && >&2 "${DC_LOGGER_STYLE_ERROR[@]}"
    local i
    for i in "$@"; do
      _dc_internal::logger::stamp "[ERROR]" "$i"
    done
    [ "$TERM" ] && [ -t 2 ] && >&2 tput op
  fi
}

#####################################
# Private helpers
#####################################

# Prefix a date to a log line and output to stderr
dc::internal::logger::stamp(){
  >&2 printf "[%s] %s\\n" "$(date)" "$*"
}
