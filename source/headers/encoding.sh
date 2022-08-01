#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

# Encoding
dc::internal::error::register ENCODING_CONVERSION_FAIL
dc::internal::error::register ENCODING_UNKNOWN
