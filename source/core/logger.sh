#!/usr/bin/env bash
##########################################################################
# Logger
# ------
# Logger
##########################################################################

#####################################
# Configuration hooks
#####################################

readonly DC_LOGGER_DEBUG=4
readonly DC_LOGGER_INFO=3
readonly DC_LOGGER_WARNING=2
readonly DC_LOGGER_ERROR=1

dc::configure::logger::setlevel() {
  local level="$1"
  [[ "$level" =~ ^-?[0-9]+$ ]] && [ "$level" -ge "$DC_LOGGER_ERROR" ] && [ "$level" -le "$DC_LOGGER_DEBUG" ] || level=$DC_LOGGER_DEBUG
  _DC_LOGGER_LEVEL=$level
  if [ "$_DC_LOGGER_LEVEL" == "$DC_LOGGER_DEBUG" ]; then
    dc::logger::warning "[Logger] YOU ARE LOGGING AT THE DEBUG LEVEL. This is NOT recommended for production use, and MAY LEAK sensitive information to stderr."
  fi
}

dc::configure::logger::setlevel::debug(){
  dc::configure::logger::setlevel $DC_LOGGER_DEBUG
}

dc::configure::logger::setlevel::info(){
  dc::configure::logger::setlevel $DC_LOGGER_INFO
}

dc::configure::logger::setlevel::warning(){
  dc::configure::logger::setlevel $DC_LOGGER_WARNING
}

dc::configure::logger::setlevel::error(){
  dc::configure::logger::setlevel $DC_LOGGER_ERROR
}

dc::configure::logger::mute() {
  _DC_LOGGER_LEVEL=0
}

#####################################
# Public API
#####################################

dc::logger::debug(){
  if [ $_DC_LOGGER_LEVEL -ge $DC_LOGGER_DEBUG ]; then
    [ ! "$TERM" ] || ( [ -t 2 ] && >&2 tput setaf $DC_COLOR_WHITE )
    local i
    for i in "$@"; do
      _dc::stamp "[DEBUG]" "$i"
    done
    [ ! "$TERM" ] || ( [ -t 2 ] && >&2 tput op )
  fi
}

dc::logger::info(){
  if [ $_DC_LOGGER_LEVEL -ge $DC_LOGGER_INFO ]; then
    [ ! "$TERM" ] || ( [ -t 2 ] && >&2 tput setaf $DC_COLOR_GREEN )
    local i
    for i in "$@"; do
      _dc::stamp "[INFO]" "$i"
    done
    [ ! "$TERM" ] || ( [ -t 2 ] && >&2 tput op )
  fi
}

dc::logger::warning(){
  if [ $_DC_LOGGER_LEVEL -ge $DC_LOGGER_WARNING ]; then
    [ ! "$TERM" ] || ( [ -t 2 ] && >&2 tput setaf $DC_COLOR_YELLOW )
    local i
    for i in "$@"; do
      _dc::stamp "[WARNING]" "$i"
    done
    [ ! "$TERM" ] || ( [ -t 2 ] && >&2 tput op )
  fi
}

dc::logger::error(){
  if [ $_DC_LOGGER_LEVEL -ge $DC_LOGGER_ERROR ]; then
    [ ! "$TERM" ] || ( [ -t 2 ] && >&2 tput setaf $DC_COLOR_RED )
    local i
    for i in "$@"; do
      _dc::stamp "[ERROR]" "$i"
    done
    [ ! "$TERM" ] || ( [ -t 2 ] && >&2 tput op )
  fi
}

#####################################
# Private helpers
#####################################

_DC_LOGGER_LEVEL=$DC_LOGGER_INFO

# Prefix a date to a log line and output to stderr
_dc::stamp(){
  >&2 echo "[$(date)] $@"
}

