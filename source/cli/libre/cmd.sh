#!/usr/bin/env bash

readonly CLI_DESC="direct access to the dc core library methods"

# Initialize
dc::commander::initialize
dc::commander::declare::arg 1 ".+" "" "method" "sh-art method to call"
dc::commander::declare::arg 2 ".+" "optional" "arguments [...arg]" "arguments to be passed to the method"
# Start commander
dc::commander::boot

# XXX will break miserably with any of the --insecure or -s flags...
"$@"
