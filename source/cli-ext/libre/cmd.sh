#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

# shellcheck disable=SC2034
readonly CLI_DESC="direct access to the dc core library methods"

dc::commander::initialize
dc::commander::declare::flag set "$DC_TYPE_STRING" "change the 'set' flags" optional
dc::commander::declare::flag bugsnag "^$" "whether to report errors to bugsnag" optional
dc::commander::declare::flag sleep "$DC_TYPE_INTEGER" "sleep for x seconds before running the command" optional
dc::commander::declare::arg 1 "$DC_TYPE_STRING" "method" "sh-art method to call"
dc::commander::declare::arg 2 "$DC_TYPE_STRING" "arguments [...arg]" "arguments to be passed to the method" optional
# Start commander
dc::commander::boot
# Add bugsnag integration
! dc::args::exist bugsnag || dc::reporter::boot c306e6d56b0bbd689991c44ef7cdeda7

# shellcheck disable=SC2086
! dc::args::exist set || set ${DC_ARG_SET:-}
! dc::args::exist sleep || sleep "${DC_ARG_SLEEP:-}"

while [ "${1:0:1}" == "-" ]; do
  shift
done
# XXX will break miserably with any of the --insecure or -s flags...
"$@"
