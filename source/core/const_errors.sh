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
readonly ERROR_NETWORK=200
# Thrown if a required argument is missing
readonly ERROR_ARGUMENT_MISSING=201
# Thrown if an argument does not match validation
readonly ERROR_ARGUMENT_INVALID=202
# Should be used to convey that a certain operation is not supported
readonly ERROR_UNSUPPORTED=203
# Generic error to denote that the operation has failed. More specific errors may be provided instead
readonly ERROR_FAILED=204
# Expectations failed on a file (not readable, writable, doesn't exist, can't be created)
readonly ERROR_FILESYSTEM=205
# System requirements
readonly ERROR_MISSING_REQUIREMENTS=206

# Crypto errors
readonly ERROR_SHASUM_FAILED=210
