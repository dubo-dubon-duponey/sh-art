#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

##########################################################################
# Logger
# ------
# Logger infrastructure
##########################################################################

dc::logger::level::set() {
  local level="${1:-}"

  # Level is an int between ERROR and DEBUG, or fallback to INFO
  # shellcheck disable=SC2015
  dc::argument::check level "$DC_TYPE_INTEGER" && [ "$level" -ge "$DC_LOGGER_ERROR" ] && [ "$level" -le "$DC_LOGGER_DEBUG" ] || {
    dc::error::detail::set "level ($level - $DC_TYPE_INTEGER - > $DC_LOGGER_ERROR and < $DC_LOGGER_DEBUG"
    return "$ERROR_ARGUMENT_INVALID"
  }

  _DC_PRIVATE_LOGGER_LEVEL="$level"
  [ "$level" != "$DC_LOGGER_DEBUG" ] ||
    _dc::private::logger::log "WARNING" "[Logger] YOU ARE LOGGING AT THE DEBUG LEVEL. This is NOT recommended for production use, and WILL LIKELY LEAK sensitive information to stderr."
}

# Sugar
dc::logger::level::set::debug(){
  dc::logger::level::set "$DC_LOGGER_DEBUG"
}

dc::logger::level::set::info(){
  dc::logger::level::set "$DC_LOGGER_INFO"
}

dc::logger::level::set::warning(){
  dc::logger::level::set "$DC_LOGGER_WARNING"
}

dc::logger::level::set::error(){
  dc::logger::level::set "$DC_LOGGER_ERROR"
}

dc::logger::mute() {
  # shellcheck disable=SC2034
  _DC_PRIVATE_LOGGER_LEVEL=0
}

dc::logger::ismute() {
  # shellcheck disable=SC2034
  [ "$_DC_PRIVATE_LOGGER_LEVEL" == 0 ] || return "$ERROR_GENERIC_FAILURE"
}

#####################################
# Public API
#####################################

dc::logger::debug(){
  _dc::private::logger::log "DEBUG" "$@"
}

dc::logger::info(){
  _dc::private::logger::log "INFO" "$@"
}

dc::logger::warning(){
  _dc::private::logger::log "WARNING" "$@"
}

dc::logger::error(){
  _dc::private::logger::log "ERROR" "$@"
}
