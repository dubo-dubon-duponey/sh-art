#!/usr/bin/env bash
##########################################################################
# Errors
# ------
# Used as exit codes, by core methods
# May be used by implementers as well
# Custom errors defined by libraries should use the 100-199 range
# Custom errors defined by applications should use the 1-99 range
##########################################################################

# Thrown by dc::http::request if a network level error occurs (eg: curl exiting abnormally)
# shellcheck disable=SC2034
readonly ERROR_NETWORK=200
# Thrown if a required argument is missing
# shellcheck disable=SC2034
readonly ERROR_ARGUMENT_MISSING=201
# Thrown if an argument does not match validation
# shellcheck disable=SC2034
readonly ERROR_ARGUMENT_INVALID=202
# Should be used to convey that a certain operation is not supported
# shellcheck disable=SC2034
readonly ERROR_UNSUPPORTED=203
# Generic error to denote that the operation has failed. More specific errors may be provided instead
# shellcheck disable=SC2034
readonly ERROR_FAILED=204
# Expectations failed on a file (not readable, writable, doesn't exist, can't be created)
# shellcheck disable=SC2034
readonly ERROR_FILESYSTEM=205
# System requirements
# shellcheck disable=SC2034
readonly ERROR_MISSING_REQUIREMENTS=206

# Crypto errors
# shellcheck disable=SC2034
readonly ERROR_SHASUM_FAILED=210
