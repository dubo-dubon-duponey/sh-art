#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

dc::internal::wrapped::ssh(){
  local ex=
  local err=

  # Requirement
  dc::require ssh

  # Debug command
  dc::logger::info "ssh $*"

  # Capture stderr, let stdout passthrough, and capture exit code
  exec 3>&1
  args=(ssh)
  args+=("$@")

  # Quote arguments
  # https://stackoverflow.com/questions/40732193/bash-how-to-use-operator-parameter-expansion-parameteroperator#41940626
  # Support in bash is shaky - presumably 4.4 is required for this to actually work, though it will not fail
  err="$("${args[@]@Q}" 2>&1 1>&3)" || ex=$?

  exec 3>&-

  if [ "$ex" != "" ]; then
    # Known error conditions
    if printf "%s" "$err" | dc::wrapped::grep -iq "Could not resolve hostname"; then
      dc::error::throw SSH_CLIENT_RESOLUTION "$*"
      return
    fi

    if printf "%s" "$err" | dc::wrapped::grep -iq "Connection refused"; then
      dc::error::throw SSH_CLIENT_CONNECTION "$*"
      return
    fi

    if printf "%s" "$err" | dc::wrapped::grep -iq "Too many authentication failures"; then
      dc::error::throw SSH_CLIENT_AUTHENTICATION "$*"
      return
    fi

    if printf "%s" "$err" | dc::wrapped::grep -iq "illegal option"; then
      dc::error::throw ARGUMENT_INVALID "$*"
      return
    fi

    dc::error::throw BINARY_UNKNOWN_ERROR "Unhandled exception from binary: $err"
  fi
}
