#!/usr/bin/env bash
## Builder
readonly CLI_VERSION="0.1.0"
readonly CLI_LICENSE="MIT License (includes shunit2, released under the Apache License)"
readonly CLI_DESC="basic unit and integration testing framework"

# Initialize
dc::commander::initialize
dc::commander::declare::arg 1 ".+" "" "source" "Test file"
# Start commander
dc::commander::boot
