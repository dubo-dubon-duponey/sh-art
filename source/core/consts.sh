#!/usr/bin/env bash
##########################################################################
# Core version constants
# ------
##########################################################################

# These are typically populated in the header, by the builder, from git info
readonly DC_LIB_VERSION=${DC_LIB_VERSION:-unknown}
readonly DC_LIB_REVISION=${DC_LIB_REVISION:-unknown}
readonly DC_LIB_BUILD_DATE=${DC_LIB_BUILD_DATE:-unknown}
readonly DC_LIB_BUILD_PLATFORM=${DC_LIB_BUILD_PLATFORM:-unknown}

readonly DC_VERSION=${DC_VERSION:-unknown}
readonly DC_REVISION=${DC_REVISION:-unknown}
readonly DC_BUILD_DATE=${DC_BUILD_DATE:-unknown}
readonly DC_BUILD_PLATFORM=${DC_BUILD_PLATFORM:-unknown}

# shellcheck disable=SC2155,SC2034
readonly DC_DEFAULT_CLI_NAME=$(basename "$0")
# shellcheck disable=SC2034
readonly DC_DEFAULT_CLI_VERSION="$DC_VERSION (dc: $DC_LIB_VERSION)"
# shellcheck disable=SC2034
readonly DC_DEFAULT_CLI_LICENSE="MIT License"
# shellcheck disable=SC2034
readonly DC_DEFAULT_CLI_DESC="A fancy piece of shcript"

# shellcheck disable=SC2034
readonly DC_TYPE_INTEGER="^-?[0-9]+$"
# shellcheck disable=SC2034
readonly DC_TYPE_UNSIGNED="^[0-9]+$"
# shellcheck disable=SC2034
readonly DC_TYPE_FLOAT="^-?[0-9]+([.][0-9]+)?$"
# shellcheck disable=SC2034
readonly DC_TYPE_BOOLEAN="^(true|false)$"
# shellcheck disable=SC2034
readonly DC_TYPE_HEX="^[a-fA-F0-9]{0,}$"
# shellcheck disable=SC2034
readonly DC_TYPE_ALPHANUM="^[a-zA-Z0-9]{0,}$"

# https://pubs.opengroup.org/onlinepubs/000095399/basedefs/xbd_chap08.html
# Not really compliant with https://en.wikipedia.org/wiki/Portable_character_set minus "=" and NUL, but then good enough
# shellcheck disable=SC2034
readonly DC_TYPE_VARIABLE="^[a-zA-Z_][a-zA-Z0-9_]{0,}$"

# shellcheck disable=SC2034
readonly DC_TYPE_STRING="^.+$"

# shellcheck disable=SC2034
readonly DC_TYPE_EMAIL="^[a-zA-Z0-9!#$%&'*+/=?^_\`{|}~.-]+@[a-zA-Z0-9!#$%&'*+/=?^_\`{|}~.-]+$"

##########################################################################
# Colors
# ------
# Used with tput - see logger and other output methods
##########################################################################
# shellcheck disable=SC2034
readonly DC_COLOR_BLACK=0
# shellcheck disable=SC2034
readonly DC_COLOR_RED=1
# shellcheck disable=SC2034
readonly DC_COLOR_GREEN=2
# shellcheck disable=SC2034
readonly DC_COLOR_YELLOW=3
# shellcheck disable=SC2034
readonly DC_COLOR_BLUE=4
# shellcheck disable=SC2034
readonly DC_COLOR_MAGENTA=5
# shellcheck disable=SC2034
readonly DC_COLOR_CYAN=6
# shellcheck disable=SC2034
readonly DC_COLOR_WHITE=7
# shellcheck disable=SC2034
readonly DC_COLOR_DEFAULT=9

##########################################################################
# Style
# ------
# Used by output methods
##########################################################################

export DC_OUTPUT_H1_START=( bold smul "setaf $DC_COLOR_WHITE" )
export DC_OUTPUT_H1_END=( sgr0 rmul op )

export DC_OUTPUT_H2_START=( bold smul "setaf $DC_COLOR_WHITE" )
export DC_OUTPUT_H2_END=( sgr0 rmul op )

export DC_OUTPUT_EMPHASIS_START=bold
export DC_OUTPUT_EMPHASIS_END=sgr0

export DC_OUTPUT_STRONG_START=( bold "setaf $DC_COLOR_RED" )
export DC_OUTPUT_STRONG_END=( sgr0 op )

export DC_OUTPUT_RULE_START=( bold smul )
export DC_OUTPUT_RULE_END=( sgr0 rmul )

export DC_OUTPUT_QUOTE_START=bold
export DC_OUTPUT_QUOTE_END=sgr0

##########################################################################
# Logger style
# ------
# Used by logger
##########################################################################

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

# shellcheck disable=SC2034
readonly DC_PLATFORM_MAC=Darwin
# shellcheck disable=SC2034
readonly DC_PLATFORM_LINUX=Linux
