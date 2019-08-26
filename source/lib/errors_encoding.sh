#!/usr/bin/env bash

true

# shellcheck disable=SC2034
readonly ERROR_ENCODING_CONVERSION_FAIL=$(dc::error::register)
# shellcheck disable=SC2034
readonly ERROR_ENCODING_UNKNOWN=$(dc::error::register)
