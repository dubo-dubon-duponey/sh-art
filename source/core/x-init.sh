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

##########################################################################
# Everything fine
##########################################################################
dc::internal::error::register NO_ERROR 0

##########################################################################
# System reserved errors, with pre-existing codepoints
##########################################################################
dc::internal::error::register SYSTEM_GENERIC_ERROR 1
dc::internal::error::register SYSTEM_SHELL_BUILTIN_MISUSE 2
dc::internal::error::register SYSTEM_COMMAND_NOT_EXECUTABLE 126
dc::internal::error::register SYSTEM_COMMAND_NOT_FOUND 127
dc::internal::error::register SYSTEM_INVALID_EXIT_ARGUMENT 128
dc::internal::error::register SYSTEM_SIGHUP 129
dc::internal::error::register SYSTEM_SIGINT 130
dc::internal::error::register SYSTEM_SIGQUIT 131
dc::internal::error::register SYSTEM_SIGABRT 134
dc::internal::error::register SYSTEM_SIGKILL 137
dc::internal::error::register SYSTEM_SIGALRM 142
dc::internal::error::register SYSTEM_SIGTERM 143
dc::internal::error::register SYSTEM_EXIT_OUT_OF_RANGE 255

##########################################################################
# Core registered errors, starting with 144
##########################################################################

### These two are refered to statically, so, they must not EVER change location
# System requirements: typically bash, grep - or anything else that was declared through the require helper
dc::internal::error::register REQUIREMENT_MISSING

# wrapped grep will return with this if there is no match
dc::internal::error::register GREP_NO_MATCH

####
# Generic error to denote that the operation has failed. More specific errors may be provided instead
dc::internal::error::register GENERIC_FAILURE

# Should be used to convey that a certain operation is not supported
dc::internal::error::register UNSUPPORTED

# any wrapped binary erroring out with an unhandled exception will return this
dc::internal::error::register BINARY_UNKNOWN_ERROR

# Any method may return this on argument validation, specifically the ::flag and ::arg validation methods
# shellcheck disable=SC2034
dc::internal::error::register ARGUMENT_INVALID

# Thrown if a required argument is missing
dc::internal::error::register ARGUMENT_MISSING

# Interactive prompts may timeout and return this
# shellcheck disable=SC2034
dc::internal::error::register ARGUMENT_TIMEOUT

# Expectations failed on a file (not readable, writable, doesn't exist, can't be created)
# shellcheck disable=SC2034
dc::internal::error::register FILESYSTEM

# Library author did something unexpected (too many errors registered for eg)
# shellcheck disable=SC2034
dc::internal::error::register LIMIT

# HTTP
dc::internal::error::register CURL_CONNECTION_FAILED
dc::internal::error::register CURL_DNS_FAILED

# XXX get rid of this
dc::internal::error::register NETWORK

# Parse command line arguments
dc::args::parse "$@"
