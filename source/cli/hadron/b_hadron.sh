#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

# Requirements
dc::require jq

HADRON_TARGET_HOST=
HADRON_TARGET_PORT=
HADRON_TARGET_USER=
HADRON_TARGET_IDENTITY=
HADRON_TARGET_RUN_TAG=
HADRON_TARGET_CONFIGURED=
HADRON_TARGET_MANAGED_NETWORKS=
HADRON_TARGET_MANAGED_NETWORKS_TO_KEEP=
HADRON_TARGET_MANAGED_NETWORKS_TO_ADD=

_hadron::plan::reset(){
  HADRON_TARGET_HOST=
  HADRON_TARGET_PORT=
  HADRON_TARGET_USER=
  HADRON_TARGET_IDENTITY=
  HADRON_TARGET_RUN_TAG=
  HADRON_TARGET_CONFIGURED=
  HADRON_TARGET_MANAGED_NETWORKS=()
  HADRON_TARGET_MANAGED_NETWORKS_TO_KEEP=()
  HADRON_TARGET_MANAGED_NETWORKS_TO_ADD=()

}

_hadron::dockerclient(){
  [ "$HADRON_TARGET_CONFIGURED" != "" ] || {
    echo "no ssh host configured. call hadron::connect first"
    exit 1
  }
  dc::ssh::client::execute "$HADRON_TARGET_USER" "$HADRON_TARGET_HOST" "$HADRON_TARGET_IDENTITY" "$HADRON_TARGET_PORT" "docker" "$@"
}

hadron::init(){
  dc::ssh::client::init
  dc::docker::client::init _hadron::dockerclient
}

# Method to start using a given host. Will test it first, then proceed.
# FIXME multiple calls to "use" will re-test for now. Implement some form of caching as an optimization to save a few seconds.
hadron::connect(){
  local user="${1:-apo}"
  local host="${2:-}"
  local identity="${3:-}"
  local port="${4:-22}"

  [ "$HADRON_TARGET_CONFIGURED" != true ] || {
    echo "Uncommitted plan. You need to deploy first before you can switch host."
    exit 1
  }

  # Check SSH is working - let it through if failing
  dc::ssh::client::execute "$user" "$host" "$identity" "$port" "exit 0"

  # Check Docker is there
  dc::ssh::client::execute "$user" "$host" "$identity" "$port" "command -v docker > /dev/null" || {
    echo "Failed to find the docker binary on the remote"
    exit 1
  }

  # Check that docker info is working
  dc::ssh::client::execute "$user" "$host" "$identity" "$port" "docker info >/dev/null 2>&1" || {
    echo "Failed to run docker info on the remote"
    exit 1
  }

  # All good? Store
  HADRON_TARGET_HOST="$host"
  HADRON_TARGET_PORT="$port"
  HADRON_TARGET_USER="$user"
  HADRON_TARGET_IDENTITY="$identity"
  HADRON_TARGET_RUN_TAG="$(date "+%Y/%m/%d-%H:%M:%S-$(uuidgen)")"
  HADRON_TARGET_CONFIGURED=true
  HADRON_TARGET_MANAGED_NETWORKS=()
  HADRON_TARGET_MANAGED_NETWORKS_TO_KEEP=()
  HADRON_TARGET_MANAGED_NETWORKS_TO_ADD=()

  # Now, get
  local all_networks
  local managed_networks
  local unmanaged_networks=()

  local name1
  local name2
  local is_managed

  # Get all hadron managed networks names
  managed_networks="$(dc::docker::client::network::list json "label=org.hadron.plan.sha" | jq -rc .Name)"
  while read -r name1; do
    HADRON_TARGET_MANAGED_NETWORKS+=("$name1")
  done <<<"$managed_networks"

  # Get all non managed net
  all_networks="$(dc::docker::client::network::list json | jq -rc .Name)"

  while read -r name1; do
    is_managed=
    [ "$name1" != host ] && [ "$name1" != bridge ] && [ "$name1" != none ] || continue
    while read -r name2; do
      [ "$name1" == "$name2" ] && {
        is_managed=true
        break
      } || continue
    done <<<"$managed_networks"
    [ "$is_managed" ] || unmanaged_networks+=("$name1")
  done <<<"$all_networks"

  [ "${#unmanaged_networks[@]}" == 0 ] || {
    dc::logger::warning "Host has user networks that are not managed by us. We are not going to touch them.\
They are potentially going to create conflicts and break deployments. Unless you know what you are doing \
it is recommended that you remove them and only manage things on this host with Hadron."
    dc::logger::warning "Here are the unmanaged user networks: ${unmanaged_networks[*]}"
  }
}

hadron_version=v0.1-dev

hadron::network(){
  local name
  local network_description
  local new_sha
  local old_sha

  network_description="$(cat "${1:-/dev/stdin}")"
  name="$(printf "%s" "$network_description" | jq -r 'select(.name != null).name')"
  new_sha="$(dc::crypto::shasum::compute <<<"$network_description")"

  local known_name
  for known_name in "${HADRON_TARGET_MANAGED_NETWORKS[@]}"; do
    if [ "$known_name" == "$name" ]; then
      old_sha="$(hadron::network::get::label "$known_name" "org.hadron.plan.sha")"
      # Same sha, just keep it and break
      if [ "$old_sha" == "$new_sha" ]; then
        HADRON_TARGET_MANAGED_NETWORKS_TO_KEEP+=("$name")
        return
      fi
      # Otherwise, same name, different content, will delete it (default) and fall into creation
      break
    fi
  done

  # Different sha, or not found to exist will have to create the new one
  HADRON_TARGET_MANAGED_NETWORKS_TO_ADD+=("$(printf '{
    "plan": %s,
    "labels": {
      "org.hadron.core.version": "%s",
      "org.hadron.plan.name": "%s",
      "org.hadron.plan.description": "%s",
      "org.hadron.plan.sha": "%s",
      "org.hadron.plan.tag": "%s"
    }
  }' "$network_description" "$hadron_version" "plan_name" "some_plan_descriptor" "$new_sha" "$HADRON_TARGET_RUN_TAG")")

}

hadron::deploy(){
  local name1
  local name2
  local keep
  local network

  # Go through the network list, delete what is NOT kept
  for name1 in "${HADRON_TARGET_MANAGED_NETWORKS[@]}"; do
    keep=
    dc::logger::info "Examining network $name1"
    for name2 in "${HADRON_TARGET_MANAGED_NETWORKS_TO_KEEP[@]}"; do
      if [ "$name1" == "$name2" ]; then
        dc::logger::info "This one is unchanged, keep it"
        keep=true
        break
      fi
    done

    if [ "$keep" == "" ]; then
        dc::logger::warning "Removing"
        # FIXME inspect containers, and remove them first
        dc::docker::client::network::remove "" "$name1"
    fi
  done

  if [ "${#HADRON_TARGET_MANAGED_NETWORKS_TO_ADD[@]}" != 0 ]; then
    # Now, go through the networks to add
    for network in "${HADRON_TARGET_MANAGED_NETWORKS_TO_ADD[@]}"; do
      dc::logger::info "Deploying new network $network"
      dc::docker::client::network::create <<<"$network"
    done
  fi

  dc::docker::client::network::list json "label=org.hadron.plan.sha" | jq .
  _hadron::plan::reset
}


###############################

hadron::network::exists(){
  hadron::network::get::id "$@" > /dev/null
}

hadron::network::get::id() {
  local name="${1:-}"
  local id

  dc::argument::check name "$DC_TYPE_STRING" || return

  id="$(dc::docker::client::network::list "" "name=$name" -q)"

  [ "$id" ] || {
    dc::error::detail::set "Network $name does not exist"
    return "$ERROR_HADRON_NO_SUCH_OBJECT"
  }

  printf "%s" "$id"
}

hadron::network::get::label() {
  local id="${1:-}"
  local label="${2:-}"

  dc::argument::check id "$DC_TYPE_STRING" || return
  dc::argument::check label "$DC_TYPE_STRING" || return

  dc::docker::client::inspect json "$id" | jq -r ".[0].Labels | select(.\"$label\" != null).\"$label\""
}

###############################################################################
# High level API
###############################################################################

hadron::info(){
  dc::docker::client::info json
}

hadron::inspect() {
  local id="${1:-}"

  dc::argument::check id "$DC_TYPE_STRING" || return

  dc::docker::client::inspect "json" "$id"
}
