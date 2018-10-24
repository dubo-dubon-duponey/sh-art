#!/usr/bin/env bash

readonly CLI_DESC="basic unit and integration testing framework"

# Initialize
dc::commander::initialize
dc::commander::declare::arg 1 ".+" "" "source" "Test file"
# Start commander
dc::commander::boot
