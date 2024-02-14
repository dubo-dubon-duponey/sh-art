#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

# Requirements
dc::require ssh

# Error registration
dc::internal::error::register SSH_CLIENT_RESOLUTION
dc::internal::error::register SSH_CLIENT_CONNECTION
dc::internal::error::register SSH_CLIENT_AUTHENTICATION
dc::internal::error::register SSH_CLIENT_ILLEGAL

#######################################################################################################################
# Private
#######################################################################################################################
_dc::wrapped::ssh(){
  local ex=
  local err=


  # Debug command
  dc::logger::info "ssh $*"

  # Capture stderr, let stdout passthrough, and capture exit code
  exec 3>&1
  args=(ssh)
  args+=("$@")

  # Quote arguments
  err="$("${args[@]Q}" 2>&1 1>&3)" || ex=$?

  exec 3>&-

  if [ "$ex" != "" ]; then
    # Known error conditions: no resolution
    printf "%s" "$err" | dc::wrapped::grep -iq "Could not resolve hostname" \
      && return "$ERROR_SSH_CLIENT_RESOLUTION" || true

    printf "%s" "$err" | dc::wrapped::grep -iq "Connection refused" \
      && return "$ERROR_SSH_CLIENT_CONNECTION" || true

    printf "%s" "$err" | dc::wrapped::grep -iq "Too many authentication failures" \
      && return "$ERROR_SSH_CLIENT_AUTHENTICATION" || true

    printf "%s" "$err" | dc::wrapped::grep -iq "illegal option" \
      && return "$ERROR_SSH_CLIENT_ILLEGAL" || true

    dc::error::detail::set "Unhandled exception from binary: $err"
    return "$ERROR_BINARY_UNKNOWN_ERROR"
  fi
  return 0
}

_DC_SSH_CLIENT_CONNECT_TIMEOUT=
_DC_SSH_CLIENT_CONTROL_MASTER=
_DC_SSH_CLIENT_CONTROL_PERSIST=
_DC_SSH_CLIENT_CONTROL_PATH=

#######################################################################################################################
# Public
#######################################################################################################################
dc::ssh::client::configure(){
  local key="$1"
  local value="$2"
  eval _DC_SSH_CLIENT_"${key}"="$value"
}

dc::ssh::client::init(){
  dc::ssh::client::configure CONNECT_TIMEOUT 5
  dc::ssh::client::configure CONTROL_MASTER auto
  dc::ssh::client::configure CONTROL_PERSIST 5m
  dc::ssh::client::configure CONTROL_PATH "$HOME/.ssh/hadron-control-%r@%h:%p"
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

  _dc::wrapped::ssh -q "${args[@]}" "$@" # $(printf '%q ' "$@")
}
