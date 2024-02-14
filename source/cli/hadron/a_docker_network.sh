#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

#######################################################################################################################
# Network commands
#  ls          List networks
#  prune       Remove all unused networks
#  rm          Remove one or more networks
#  connect     Connect a container to a network
#  create      Create a network
#  disconnect  Disconnect a container from a network
#  inspect     Display detailed information on one or more networks
#######################################################################################################################

dc::docker::client::network::list() {
  local com=(network list)

  local format="${1:-}"
  [ "$format" == "" ] || com+=(--format "$format")
  shift || true

  local filter="${1:-}"
  [ "$filter" == "" ] || com+=(--filter "$filter")
  shift || true

  _dc::docker::client::execute "${com[@]}" "$@"
}

dc::docker::client::network::prune() {
  local com=(network prune)

  local filter="${1:-}"
  [ "$filter" == "" ] || com+=(--filter "$filter")
  shift || true

  local force="${1:-}"
  [ "$force" == "" ] || com+=(--force)
  shift || true

  _dc::docker::client::execute "${com[@]}" "$@"
}

dc::docker::client::network::remove() {
  local com=(network remove)

  local force="${1:-}"
  [ "$force" == "" ] || com+=(--force)
  shift || true

  _dc::docker::client::execute "${com[@]}" "$@"
}

#      --alias strings           Add network-scoped alias for the container
#      --driver-opt strings      driver options for the network
#      --ip string               IPv4 address (e.g., "172.30.100.104")
#      --ip6 string              IPv6 address (e.g., "2001:db8::33")
#      --link list               Add link to another container
#      --link-local-ip strings   Add a link-local address for the container
# FIXME missing options to implement
# Note that right now arguments are passthrough, so, additional options may be provided before net and container
dc::docker::client::network::connect() {
  local com=(network connect)

  local network="${1:-}"
  local container="${2:-}"

  #dc::argument::check network "$DC_TYPE_STRING" || return
  #dc::argument::check container "$DC_TYPE_STRING" || return
  # [ ! "$ip" ] || dc::argument::check ip "$DC_TYPE_IPV4" || return
  # [ ! "$alias" ] || dc::argument::check alias "$DC_TYPE_STRING" || return

  _dc::docker::client::execute "${com[@]}" "$@"
}

dc::docker::client::network::disconnect() {
  local com=(network disconnect)

  local force="${1:-}"
  [ "$force" == "" ] || com+=(--force)
  shift || true

  local network="${1:-}"
  local container="${2:-}"

  dc::argument::check network "$DC_TYPE_STRING" || return
  dc::argument::check container "$DC_TYPE_STRING" || return

  _dc::docker::client::execute "${com[@]}" "$network" "$container"
}

dc::docker::client::network::inspect() {
  local com=(network inspect)

  local format="${1:-}"
  [ "$format" == "" ] || com+=(--format "$format")
  shift || true

  _dc::docker::client::execute "${com[@]}" "$@"
}


# Missing
#      --ipam-driver string   IP Address Management Driver (default "default")
#      --ipam-opt map         Set IPAM driver specific options (default map[])
#      --scope string         Control the network's scope
# XXX not proper:
# maps for aux, subnet, gateway
# probably also miss ip6_table
dc::docker::client::network::create() {
  local com=(network create)

  local config="${1:-/dev/stdin}"

  local name
  local netconfig

#  -d, --driver string        Driver to manage the Network (default "bridge")
  local driver
#      --attachable           Enable manual container attachment
  local attachable
#      --internal             Restrict external access to the network
  local internal
#      --ipv6                 Enable IPv6 networking
  local ipv6

  local subnet
  local gateway
  local ip_range
  local parent
  local ipvlan_mode

  netconfig="$(cat "$config")"

  # Ensure we avoid nasty side effects ("null" being a valid string)
  name="$(printf "%s" "$netconfig" | jq -r 'select(.plan.name != null).plan.name')"
  driver="$(printf "%s" "$netconfig" | jq -r 'select(.plan.driver != null).plan.driver')"

  # It doesn't really matter if we get a null or an empty value here, it will fail validating as a boolean
  attachable="$(printf "%s" "$netconfig" | jq -r .plan.attachable)"
  internal="$(printf "%s" "$netconfig" | jq -r .plan.internal)"
  ipv6="$(printf "%s" "$netconfig" | jq -r .plan.ipv6)"

  dc::argument::check name "$DC_TYPE_STRING" || return
  dc::argument::check driver "$DC_TYPE_STRING" || return
  dc::argument::check attachable "$DC_TYPE_BOOLEAN" || return
  dc::argument::check internal "$DC_TYPE_BOOLEAN" || return
  dc::argument::check ipv6 "$DC_TYPE_BOOLEAN" || return

  com+=("--driver" "$driver")

  [ "$internal" == false ] || com+=("--internal")
  [ "$attachable" == false ] || com+=("--attachable")
  [ "$ipv6" == false ] || com+=("--ipv6")

#      --subnet strings       Subnet in CIDR format that represents a network segment
#      --gateway strings      IPv4 or IPv6 Gateway for the master subnet
#      --ip-range strings     Allocate container ip from a sub-range
#      --aux-address map      Auxiliary IPv4 or IPv6 addresses used by Network driver (default map[])

  # All these are optional, so, avoid catching "null"s
  subnet="$(printf "%s" "$netconfig" | jq -r 'select(.plan.subnet != null).plan.subnet[]')"
  gateway="$(printf "%s" "$netconfig" | jq -r 'select(.plan.gateway != null).plan.gateway')"
  ip_range="$(printf "%s" "$netconfig" | jq -r 'select(.plan.ip_range != null).plan.ip_range')"
  aux_address="$(printf "%s" "$netconfig" | jq -r 'select(.plan.aux_address != null).plan.ip')"

  [ ! "$subnet" ] || {
    # XXX broken for ipv6
    # dc::argument::check subnet "$DC_TYPE_CIDR" || return
    local sub
    while read -r sub; do
      echo "lolling $sub"
      com+=(--subnet "$sub")
    done <<<"$subnet"
  }
  [ ! "$gateway" ] || {
    dc::argument::check gateway "$DC_TYPE_IPV4" || return
    com+=(--gateway "$gateway")
  }
  [ ! "$ip_range" ] || {
    dc::argument::check ip_range "$DC_TYPE_CIDR" || return
    com+=(--ip-range "$ip_range")
  }
  [ ! "$aux_address" ] || {
    dc::argument::check aux_address "$DC_TYPE_IP" || return
    com+=(--aux-address "$aux_address")
  }

#  -o, --opt map              Set driver specific options (default map[])
  # Only ip or mac vlan
  parent="$(printf "%s" "$netconfig" | jq -r 'select(.plan.parent != null).plan.parent')"
  ipvlan_mode="$(printf "%s" "$netconfig" | jq -r 'select(.plan.ipvlan_mode != null).plan.ipvlan_mode')"

  [ ! "$ipvlan_mode" ] || com+=(--opt ipvlan_mode "$ipvlan_mode")
  [ ! "$parent" ] || com+=(--opt parent "$parent")

#      --label list           Set metadata on a network
  while read -r label; do
    com+=(--label "$label")
  done < <(printf "%s" "$netconfig" | jq -r 'select(.labels != null).labels | . as $in| keys[] | [. + "=" + $in[.]] | add')
#  done < <(jq -r 'select(.labels != null).labels | . as $in| keys[] | [., $in[.]] | map(tostring+"=") | add')

  _dc::docker::client::execute "${com[@]}" "$name"
}

