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

# System requirements
dc::error::register ERROR_REQUIREMENT_MISSING

# Generic error to denote that the operation has failed. More specific errors may be provided instead
dc::error::register ERROR_FAILED

# Should be used to convey that a certain operation is not supported
dc::error::register ERROR_UNSUPPORTED

# wrapped grep will return with this if there is no match
dc::error::register ERROR_GREP_NO_MATCH

# any wrapped binary erroring out with an unhandled exception will return this
dc::error::register ERROR_BINARY_UNKNOWN_ERROR

# Any method may return this on argument validation, specifically the ::flag and ::arg validation methods
# shellcheck disable=SC2034
dc::error::register ERROR_ARGUMENT_INVALID

# Thrown if a required argument is missing
dc::error::register ERROR_ARGUMENT_MISSING

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


export ERROR_SYSTEM_1=1
export ERROR_SYSTEM_2=2
export ERROR_SYSTEM_126=126
export ERROR_SYSTEM_127=127
export ERROR_SYSTEM_128=128
export ERROR_SYSTEM_255=255

readonly ERROR_SYSTEM_1
readonly ERROR_SYSTEM_2
readonly ERROR_SYSTEM_126
readonly ERROR_SYSTEM_127
readonly ERROR_SYSTEM_128
readonly ERROR_SYSTEM_255

export ERROR_SYSTEM_SIGHUP=129
export ERROR_SYSTEM_SIGINT=130
export ERROR_SYSTEM_SIGQUIT=131
export ERROR_SYSTEM_SIGABRT=134
export ERROR_SYSTEM_SIGKILL=137
export ERROR_SYSTEM_SIGALRM=142
export ERROR_SYSTEM_SIGTERM=143

readonly ERROR_SYSTEM_SIGHUP
readonly ERROR_SYSTEM_SIGINT
readonly ERROR_SYSTEM_SIGQUIT
readonly ERROR_SYSTEM_SIGABRT
readonly ERROR_SYSTEM_SIGKILL
readonly ERROR_SYSTEM_SIGALRM
readonly ERROR_SYSTEM_SIGTERM
