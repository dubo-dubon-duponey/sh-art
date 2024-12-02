#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

#######################################################################################################################
# Private
#######################################################################################################################

_DC_SSH_CLIENT_CONNECT_TIMEOUT=
_DC_SSH_CLIENT_CONTROL_MASTER=
_DC_SSH_CLIENT_CONTROL_PERSIST=
_DC_SSH_CLIENT_CONTROL_PATH=

dc::internal::wrapped::ssh(){
  local ex=
  local err=
  local quoted_args=()
  local arg

  for arg in "$@"; do
    quoted_args+=("$(printf '%q' "$arg")")
  done


  # Requirement
  dc::require ssh

  # Debug command
  dc::logger::debug "ssh $*"

  # Capture stderr, let stdout passthrough, and capture exit code
  exec 3>&1

  # Quote arguments
  # https://stackoverflow.com/questions/40732193/bash-how-to-use-operator-parameter-expansion-parameteroperator#41940626
  # Support in bash is shaky - presumably 4.4 is required for this to actually work, though it will not fail
  err="$(ssh "${quoted_args[@]}" 2>&1 1>&3)" || ex=$?

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

    if printf "%s" "$err" | dc::wrapped::grep -iq "(?:Too many authentication failures|Permission denied)"; then
      dc::error::throw SSH_CLIENT_AUTHENTICATION "$*"
      return
    fi

    # Dear open-ssh, we are applauding the creativity here, using different synonyms from one release to the other
    # Suggestions for you for the upcoming releases: un-allowed, dis-allowed, foobar-ed, not right, un-groakable,
    # or... BLAH!
    if printf "%s" "$err" | dc::wrapped::grep -iq "(?:illegal|unknown|unrecognized) option"; then
      dc::error::throw ARGUMENT_INVALID "$*"
      return
    fi

    if printf "%s" "$err" | dc::wrapped::grep -iq "Operation timed out"; then
      dc::error::throw SSH_CLIENT_CONNECTION "$*"
      return
    fi

    dc::error::throw BINARY_UNKNOWN_ERROR "Unhandled exception from binary: $err"
  fi
}

#######################################################################################################################
# Public
#######################################################################################################################
dc::ssh::client::configure(){
  local key="$1"
  local value="$2"
  eval _DC_SSH_CLIENT_"${key}"="$value"
}

dc::ssh::client::init(){
  local prefix="${1:-shart}"
  dc::ssh::client::configure CONNECT_TIMEOUT 5
  dc::ssh::client::configure CONTROL_MASTER auto
  dc::ssh::client::configure CONTROL_PERSIST 5m
  dc::ssh::client::configure CONTROL_PATH "$HOME/.ssh/control-${prefix}-%r@%h:%p"
}

dc::ssh::client::execute(){
  local user="${1:-}"
  local host="${2:-}"
  local identity="${3:-}"
  local port="${4:-}"
  shift
  shift
  shift
  shift

  local args=()
  [ "$_DC_SSH_CLIENT_CONNECT_TIMEOUT" == "" ] || args+=(-o ConnectTimeout="$_DC_SSH_CLIENT_CONNECT_TIMEOUT")
  [ "$_DC_SSH_CLIENT_CONTROL_MASTER" == "" ]  || args+=(-o ControlMaster="$_DC_SSH_CLIENT_CONTROL_MASTER")
  [ "$_DC_SSH_CLIENT_CONTROL_PERSIST" == "" ] || args+=(-o ControlPersist="$_DC_SSH_CLIENT_CONTROL_PERSIST")
  [ "$_DC_SSH_CLIENT_CONTROL_PATH" == "" ] || args+=(-o ControlPath="$_DC_SSH_CLIENT_CONTROL_PATH")
  [ "$identity" == "" ] || args+=(-i "$identity")
  [ "$port" == "" ] || args+=(-p "$port")

  args+=("$user@$host")

  dc::internal::wrapped::ssh "${args[@]}" "$@" || return
}
