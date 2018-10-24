#!/usr/bin/env bash

readonly CLI_VERSION="0.0.1"
readonly CLI_LICENSE="MIT License"
readonly CLI_DESC="direct access to the dc core library methods"
readonly CLI_USAGE="[-s] method-name [...arguments]"

# Initialize
dc::commander::initialize

# Start commander
dc::commander::boot

"$@"
