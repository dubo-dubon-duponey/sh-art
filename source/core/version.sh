#!/usr/bin/env bash
##########################################################################
# Core version constants
# ------
##########################################################################

# Thrown by dc::http::request if a network level error occurs (eg: curl exiting abnormally)
readonly DC_VERSION=${DC_VERSION:-unknown}
# Thrown if a required argument is missing
readonly DC_REVISION=${DC_REVISION:-unknown}
readonly DC_BUILD_DATE=${DC_BUILD_DATE:-unknown}
