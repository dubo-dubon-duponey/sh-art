#!/usr/bin/env bash

true

# shellcheck disable=SC2034
readonly DC_LOGGER_DEBUG=4
# shellcheck disable=SC2034
readonly DC_LOGGER_INFO=3
# shellcheck disable=SC2034
readonly DC_LOGGER_WARNING=2
# shellcheck disable=SC2034
readonly DC_LOGGER_ERROR=1

export DC_LOGGER_STYLE_DEBUG=( setaf "$DC_COLOR_WHITE" )
export DC_LOGGER_STYLE_INFO=( setaf "$DC_COLOR_GREEN" )
export DC_LOGGER_STYLE_WARNING=( setaf "$DC_COLOR_YELLOW" )
export DC_LOGGER_STYLE_ERROR=( setaf "$DC_COLOR_RED" )

dc::configure::logger::setlevel::info
