#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

# Requirements
dc::require jq

HADRON_TARGET_HOST=
HADRON_TARGET_PORT=
HADRON_TARGET_USER=
HADRON_TARGET_IDENTITY=
HADRON_TARGET_CONFIGURED=

HADRON_TARGET_RUN_TAG=
HADRON_TARGET_DESIRED_NETWORKS=
HADRON_TARGET_DESIRED_CONTAINERS=
HADRON_TARGET_DESIRED_IMAGES=

_PRIVATE_HADRON_NETWORK_FORCE_REFRESH=true
_PRIVATE_HADRON_NETWORK_CACHE=
_PRIVATE_HADRON_CONTAINER_FORCE_REFRESH=true
_PRIVATE_HADRON_CONTAINER_CACHE=


hadron_version=v0.1-dev

_hadron::plan::reset(){
  HADRON_TARGET_HOST=
  HADRON_TARGET_PORT=
  HADRON_TARGET_USER=
  HADRON_TARGET_IDENTITY=
  HADRON_TARGET_CONFIGURED=

  # Reset the plan
  HADRON_TARGET_RUN_TAG="$(date "+%Y/%m/%d-%H:%M:%S-$(uuidgen)")"
  HADRON_TARGET_DESIRED_NETWORKS=()
  HADRON_TARGET_DESIRED_CONTAINERS=()
  HADRON_TARGET_DESIRED_IMAGES=()

  _PRIVATE_HADRON_NETWORK_FORCE_REFRESH=true
  _PRIVATE_HADRON_NETWORK_CACHE=
  _PRIVATE_HADRON_CONTAINER_FORCE_REFRESH=true
  _PRIVATE_HADRON_CONTAINER_CACHE=
}

_hadron::dockerclient(){
  [ "$HADRON_TARGET_CONFIGURED" != "" ] || {
    echo "no ssh host configured. call hadron::connect first"
    exit 1
  }
  dc::ssh::client::execute "$HADRON_TARGET_USER" "$HADRON_TARGET_HOST" "$HADRON_TARGET_IDENTITY" "$HADRON_TARGET_PORT" "docker" "$@"
}

hadron::init(){
  # Initialize SSH and point the master connect to hadron prefix
  dc::ssh::client::init "hadron"
  # Initialize the docker client to be our freshly configured ssh+docker provider
  dc::docker::client::init _hadron::dockerclient
}

# Allow querying the list of network with caching
hadron::network::query(){
  [ "$_PRIVATE_HADRON_NETWORK_FORCE_REFRESH" != true ] || {
    _PRIVATE_HADRON_NETWORK_FORCE_REFRESH=
    _PRIVATE_HADRON_NETWORK_CACHE="$(dc::docker::client::network::list json)"
  }
  printf "%s" "$_PRIVATE_HADRON_NETWORK_CACHE"
}

hadron::container::query(){
  [ "$_PRIVATE_HADRON_CONTAINER_FORCE_REFRESH" != true ] || {
    _PRIVATE_HADRON_CONTAINER_FORCE_REFRESH=
    _PRIVATE_HADRON_CONTAINER_CACHE="$(dc::docker::client::container::list all json)"
  }
  printf "%s" "$_PRIVATE_HADRON_CONTAINER_CACHE"
}


# Method to start using a given host. Will test it first, then proceed.
# FIXME multiple calls to "connect" will re-test for now. Implement some form of caching as an optimization to save a few seconds.
hadron::connect(){
  local user="${1:-apo}"
  local host="${2:-}"
  local identity="${3:-}"
  local port="${4:-22}"

  # Unconfigured, bail out
  [ "$HADRON_TARGET_CONFIGURED" != true ] || {
    echo "Uncommitted plan. You need to deploy first before you can switch host."
    exit 1
  }

  # Check that SSH is working - let it through if failing
  dc::ssh::client::execute "$user" "$host" "$identity" "$port" exit 0 || return

  # Check Docker is there
  dc::ssh::client::execute "$user" "$host" "$identity" "$port" command -v docker >/dev/null || {
    echo "Failed to find the docker binary on the remote."
    exit 1
  }

  # Check that docker info is working
  dc::ssh::client::execute "$user" "$host" "$identity" "$port" docker info >/dev/null 2>&1 || {
    echo "Failed to run docker info on the remote. Is the daemon started?"
    exit 1
  }

  # All good? Store
  _hadron::plan::reset

  # And set the host props
  HADRON_TARGET_HOST="$host"
  HADRON_TARGET_PORT="$port"
  HADRON_TARGET_USER="$user"
  HADRON_TARGET_IDENTITY="$identity"
  HADRON_TARGET_CONFIGURED=true
}

# Networks do not depend on nothing, we can resolve right away
hadron::network(){
  local description
  local sha

  description="$(cat "${1:-/dev/stdin}")"
  sha="$(dc::crypto::shasum::compute <<<"$description")"

  # Otherwise, we will have to create the new one
  HADRON_TARGET_DESIRED_NETWORKS+=("$(printf '{
    "plan": %s,
    "labels": {
      "org.hadron.core.version": "%s",
      "org.hadron.plan.name": "%s",
      "org.hadron.plan.description": "%s",
      "org.hadron.plan.sha": "%s",
      "org.hadron.plan.tag": "%s"
    }
  }' "$description" "$hadron_version" "plan_name" "some_plan_descriptor" "$sha" "$HADRON_TARGET_RUN_TAG")")

}

hadron::image(){
  true
}

# Containers cannot be resolved until we fully resolve networks and images
hadron::container(){
  local description
  local image
  local sha

  description="$(cat "${1:-/dev/stdin}")"
  image="$(jq -rc .image - <<<"$description")"
  sha="$(dc::crypto::shasum::compute <<<"$description")"

  # Different sha, or not found to exist will have to create the new one
  HADRON_TARGET_DESIRED_CONTAINERS+=("$(printf '{
    "plan": %s,
    "labels": {
      "org.hadron.core.version": "%s",
      "org.hadron.plan.name": "%s",
      "org.hadron.plan.description": "%s",
      "org.hadron.plan.sha": "%s",
      "org.hadron.plan.tag": "%s"
    }
  }' "$description" "$hadron_version" "plan_name" "some_plan_descriptor" "$sha" "$HADRON_TARGET_RUN_TAG")")

  HADRON_TARGET_DESIRED_IMAGES+=("$image")
}

_hadron::deploy::image(){
  local name
  local id
  local new_id

  local candidate

  for name in "${HADRON_TARGET_DESIRED_IMAGES[@]}"; do
    id="$(jq -rc .[].Id <(dc::docker::client::image::inspect json "$name"))"
    # Force pull it as a check
    dc::docker::client::image::pull "" "$name" >/dev/null
    new_id="$(jq -rc .[].Id <(dc::docker::client::image::inspect json "$name"))"
    if [ "$new_id" != "$id" ]; then
      # List the containers using the old version of the image and remove them
      while read -r candidate; do
        [ "$candidate" ] || break
        dc::logger::info "   ... removing attached resource $candidate"
        # We are destroying containers - we will need to refresh state
        _PRIVATE_HADRON_CONTAINER_FORCE_REFRESH=true
        # XXX verify what force does, and if it would be better to stop, then rm
        dc::docker::client::container::remove force volumes "$candidate" >/dev/null
      # XXX note: this is going to delete whatever is attached to it, managed or not
      # We could be nicer here
      done < <(jq -r '.Names' <(dc::docker::client::container::list all json ancestor="$id"))
      # Now, GC the previous image
      dc::docker::client::image::remove "" "" "$id" >/dev/null
    fi
  done

#  done < <(jq -rc '. | select(.Labels | test("(^|,)org.hadron.plan.sha=.+")) | .Image' <(hadron::container::query))
}

_hadron::deploy::unit(){
  local type="$1"
  shift
  local key="Name"
  local create="create"
  [ "$type" != "container" ] || {
    key+="s"
    create="run"
  }

  local definition
  local name
  local sha

  local keeplist
  local rmlist
  local addlist
  local keep
  local candidate

  # First, go through the list of objects to add and see if there is any that can be kept
  keeplist=()
  addlist=()
  dc::logger::info "1. looking at desired state to figure out what will need to be created and what can be kept"
  for definition in "$@"; do
    # Extract the name and sha of the object we want to add
    name="$(jq -rc '.plan.name' - <<<"$definition")"
    sha="$(jq -rc '.labels."org.hadron.plan.sha"' - <<<"$definition")"

    dc::logger::info " > examining $name ($sha)"
    # If there is an existing object that matches the sha, mark it as "keep"
    [ "$(jq --arg sha "$sha" '. | select(.Labels | test("(^|,)org.hadron.plan.sha=" + $sha))' <(hadron::"$type"::query))" ] && {
      dc::logger::info " > found it - nothing to be done"
      keeplist+=("$name")
    } || {
      dc::logger::info " > will need to create it"
      addlist+=("$definition")
    }
  done

  # Second, go through all managed objects and delete whatever is not in the keep list
  dc::logger::info "2. looking at the current state to figure out what will need to be garbage collected"
  rmlist=()
  while read -r name; do
    dc::logger::info " > examining $name"
    [ "$name" ] || break
    keep=
    for candidate in "${keeplist[@]}"; do
      if [ "$name" == "$candidate" ]; then
        dc::logger::info " > to be kept"
        keep=true
        break
      fi
    done
    [ "$keep" ] || {
      dc::logger::info " > to be removed"
      rmlist+=("$name")
    }
  done < <(jq -rc '. | select(.Labels | test("(^|,)org.hadron.plan.sha=.+")) | .'"$key" <(hadron::"$type"::query))

  dc::logger::info "3. Garbage collecting"
  # Third, do the actual cleanup
  for name in "${rmlist[@]}"; do
    dc::logger::info " ... destroying $name"
    [ "$type" == "network" ] && {
      # Read the resources attached to it and destroy them
      while read -r candidate; do
        [ "$candidate" ] || break
        dc::logger::info "   ... removing attached resource $candidate"
        # We are destroying containers - we will need to refresh state
        _PRIVATE_HADRON_CONTAINER_FORCE_REFRESH=true
        # XXX verify what force does, and if it would be better to stop, then rm
        dc::docker::client::container::remove force volumes "$candidate" >/dev/null
      # XXX note: this is going to delete whatever is attached to it, managed or not
      done < <(jq -r '.[].Containers | map(.) | .[] | .Name' <(dc::docker::client::"$type"::inspect json "$name"))

      # We are destroying containers - we will need to refresh state
      _PRIVATE_HADRON_NETWORK_FORCE_REFRESH=true
      # Finally remove the object itself
      dc::docker::client::"$type"::remove "" "$name" >/dev/null
    } || {
      # We are destroying containers - we will need to refresh state
      _PRIVATE_HADRON_CONTAINER_FORCE_REFRESH=true
      # Finally remove the object itself
      dc::docker::client::"$type"::remove force volumes "$name" >/dev/null
    }
  done

  dc::logger::info "4. Creation"
  # Finally, create what needs be
  for definition in "${addlist[@]}"; do
    name="$(jq -rc '.plan.name' - <<<"$definition")"
    dc::logger::info " ... creating $name"
    # XXX just force refresh the right type
    _PRIVATE_HADRON_NETWORK_FORCE_REFRESH=true
    _PRIVATE_HADRON_CONTAINER_FORCE_REFRESH=true
    dc::docker::client::"$type"::"$create" <<<"$definition" >/dev/null
  done
}

hadron::deploy(){
  dc::logger::info "Deployment started"

  dc::logger::info "A. Networks"
  _hadron::deploy::unit network "${HADRON_TARGET_DESIRED_NETWORKS[@]}"

  dc::logger::info "B. Images"
  _hadron::deploy::image

  dc::logger::info "C. Containers"
  _hadron::deploy::unit container "${HADRON_TARGET_DESIRED_CONTAINERS[@]}"

  # Pruning images by default
  dc::docker::client::image::prune "" "" force >/dev/null

  _hadron::plan::reset
}

###############################################################################
# High level API
###############################################################################

#hadron::info(){
#  dc::docker::client::info json
#}

#hadron::inspect() {
#  local id="${1:-}"

#  dc::argument::check id "$DC_TYPE_STRING" || return

#  dc::docker::client::inspect "json" "$id"
#}

