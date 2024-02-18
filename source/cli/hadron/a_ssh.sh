#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

# Error registration
# Domain resolution failed
dc::internal::error::register SSH_CLIENT_RESOLUTION
# Connection refused
dc::internal::error::register SSH_CLIENT_CONNECTION
# Authentication failed
dc::internal::error::register SSH_CLIENT_AUTHENTICATION

#######################################################################################################################
# Private
#######################################################################################################################

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
