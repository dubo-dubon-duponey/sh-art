#!/usr/bin/env bash
##########################################################################
# Errors
# ------
# Used as exit codes, by core methods
# May be used by implementers as well
# bash reserved: 1, 2, 126-143, 255
# dc core errors use the range 144-254
# custom errors defined by apps & libraries should use the 3-125 range
##########################################################################

# wrapped grep will return with this if there is no match
dc::error::register ERROR_GREP_NO_MATCH

# any wrapped binary erroring out with an unhandled exception will return this
dc::error::register ERROR_BINARY_UNKNOWN_ERROR

# System requirements
dc::error::register ERROR_MISSING_REQUIREMENTS

# Any method may return this on argument validation, specifically the ::flag and ::arg validation methods
# shellcheck disable=SC2034
dc::error::register ERROR_ARGUMENT_INVALID

# Interactive prompts may timeout and return this
# shellcheck disable=SC2034
dc::error::register ERROR_ARGUMENT_TIMEOUT

# Expectations failed on a file (not readable, writable, doesn't exist, can't be created)
# shellcheck disable=SC2034
dc::error::register ERROR_FILESYSTEM

################## LIBRARY
# Crypto
dc::error::register ERROR_CRYPTO_SHASUM_WRONG_ALGORITHM
dc::error::register ERROR_CRYPTO_SHASUM_FILE_ERROR
dc::error::register ERROR_CRYPTO_SSL_INVALID_KEY
dc::error::register ERROR_CRYPTO_SSL_WRONG_PASSWORD
dc::error::register ERROR_CRYPTO_SSL_WRONG_ARGUMENTS
dc::error::register ERROR_CRYPTO_SHASUM_VERIFY_ERROR
dc::error::register ERROR_CRYPTO_PEM_NO_SUCH_HEADER

# Encoding
dc::error::register ERROR_ENCODING_CONVERSION_FAIL
dc::error::register ERROR_ENCODING_UNKNOWN

# HTTP
dc::error::register ERROR_CURL_CONNECTION_FAILED
dc::error::register ERROR_CURL_DNS_FAILED


# Thrown by dc::http::request if a network level error occurs (eg: curl exiting abnormally)
# shellcheck disable=SC2034
readonly ERROR_NETWORK=200
# Thrown if a required argument is missing
# shellcheck disable=SC2034
readonly ERROR_ARGUMENT_MISSING=201
# Should be used to convey that a certain operation is not supported
# shellcheck disable=SC2034
readonly ERROR_UNSUPPORTED=203
# Generic error to denote that the operation has failed. More specific errors may be provided instead
# shellcheck disable=SC2034
readonly ERROR_FAILED=204

