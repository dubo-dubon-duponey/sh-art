#!/usr/bin/env bash

true
# shellcheck disable=SC2034
readonly CLI_DESC="direct access to the dc core library methods"

# Initialize
dc::commander::initialize
dc::commander::declare::arg 1 ".+" "method" "sh-art method to call"
dc::commander::declare::arg 2 ".+" "arguments [...arg]" "arguments to be passed to the method" optional
# Start commander
dc::commander::boot
# Add bugsnag integration
dc::reporter::boot c306e6d56b0bbd689991c44ef7cdeda7

# XXX will break miserably with any of the --insecure or -s flags...
"$@"
