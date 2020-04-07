#!/usr/bin/env bash

dc::wrapped::docker(){
  dc::require docker || return

  local err

  exec 3>&1
  dc::logger::info "docker $*"

  if ! err="$(docker "$@" 2>&1 1>&3)"; then
    exec 3>&-

    # Known error conditions
    printf "%s" "$err" | dc::wrapped::grep -q "docker: '.*' is not a docker command." \
      && return "$ERROR_DOCKER_WRONG_COMMAND"

    printf "%s" "$err" | dc::wrapped::grep -q "Error: No such " \
      && return "$ERROR_DOCKER_NO_SUCH_OBJECT"

    printf "%s" "$err" | dc::wrapped::grep -q "Error response from daemon: plugin \"[^\"]+\" not found" \
      && return "$ERROR_DOCKER_MISSING_PLUGIN"

    # Generic unspecified error
    dc::error::detail::set "$err"
    return "$ERROR_BINARY_UNKNOWN_ERROR"
  fi

  printf "%s" "$err" | dc::wrapped::grep -q "COMMAND --help' for more information on a command" \
    && { dc::error::detail::set "$err" && return "$ERROR_DOCKER_WRONG_SYNTAX"; }

  exec 3>&-
}

###############################################################################
# Generic
###############################################################################
docker::host(){
  local user="$1"
  local host="$2"
  local port="$3"

  dc::argument::check user "$DC_TYPE_USER" || return
  dc::argument::check host "$DC_TYPE_DOMAIN_OR_IP" || return
  dc::argument::check port "$DC_TYPE_UNSIGNED" || return

  DOCKER_HOST="$(printf "ssh://%s@%s:%s" "$user" "$host" "$port")"
  export DOCKER_HOST
}

docker::info(){
  dc::wrapped::docker info
}

docker::inspect() {
  local id="${1:-}"

  dc::argument::check id "$DC_TYPE_STRING" || return

  dc::wrapped::docker inspect "$id"
}


###############################################################################
# Network
###############################################################################
docker::network::lookup() {
  local name="${1:-}"
  local id

  dc::argument::check name "$DC_TYPE_STRING" || return

  id="$(dc::wrapped::docker network ls -q --filter "name=$name")"

  [ "$id" ] || {
    dc::error::detail::set "Network $name does not exist"
    return "$ERROR_DOCKER_NO_SUCH_OBJECT"
  }

  printf "%s" "$id"
}

docker::network::inspect() {
  local name="${1:-}"

  dc::argument::check name "$DC_TYPE_STRING" || return

  docker::inspect "$1"
}

docker::network::remove() {
  local id="${1:-}"

  dc::argument::check id "$DC_TYPE_STRING" || return

  dc::wrapped::docker network rm "$id"
}

docker::network::create() {
  local config="${1:-/dev/stdin}"
  local net
  local name

  local attachable
  local internal
  local ipv6

  local subnet
  local gateway
  local ip_range
  local parent
  local ipvlan_mode

  net="$(cat "$config")"

  # Ensure we avoid nasty side effects ("null" being a valid string)
  name="$(printf "%s" "$net" | jq -rc 'select(.name != null).name')"
  driver="$(printf "%s" "$net" | jq -rc 'select(.driver != null).driver')"

  # It doesn't really matter if we get a null or an empty value here, it will fail validating as a boolean
  attachable=$(printf "%s" "$net" | jq -rc .attachable)
  internal=$(printf "%s" "$net" | jq -rc .internal)
  ipv6=$(printf "%s" "$net" | jq -rc .ipv6)

  # All these are optional, so, avoid catching "null"s
  subnet="$(printf "%s" "$net" | jq -rc 'select(.subnet != null).subnet')"
  gateway="$(printf "%s" "$net" | jq -rc 'select(.gateway != null).gateway')"
  ip_range="$(printf "%s" "$net" | jq -rc 'select(.ip_range != null).ip_range')"
  parent="$(printf "%s" "$net" | jq -rc 'select(.parent != null).parent')"
  ipvlan_mode="$(printf "%s" "$net" | jq -rc 'select(.ipvlan_mode != null).ipvlan_mode')"

  dc::argument::check name "$DC_TYPE_STRING" || return
  dc::argument::check driver "$DC_TYPE_STRING" || return
  dc::argument::check attachable "$DC_TYPE_BOOLEAN" || return
  dc::argument::check internal "$DC_TYPE_BOOLEAN" || return
  dc::argument::check ipv6 "$DC_TYPE_BOOLEAN" || return

  args=("--driver" "$driver")
  args+=("--internal=$internal")
  args+=("--attachable=$attachable")
  args+=("--ipv6=$ipv6")


  [ ! "$subnet" ] || {
    dc::argument::check subnet "$DC_TYPE_CIDR" || return
    args+=(--subnet "$subnet")
  }
  [ ! "$gateway" ] || {
    dc::argument::check gateway "$DC_TYPE_IPV4" || return
    args+=(--gateway "$gateway")
  }
  [ ! "$ip_range" ] || {
    dc::argument::check ip_range "$DC_TYPE_CIDR" || return
    args+=(--ip-range "$ip_range")
  }

  [ ! "$ipvlan_mode" ] || args+=(--opt ipvlan_mode "$ipvlan_mode")
  [ ! "$parent" ] || args+=(--opt parent "$parent")

  while read -r label; do
    args+=(--label "$label")
  done < <(printf "%s" "$net" | jq -rc 'select(.labels != null).labels | . as $in| keys[] | [. + "=" + $in[.]] | add')
#  done < <(jq -rc 'select(.labels != null).labels | . as $in| keys[] | [., $in[.]] | map(tostring+"=") | add')

  dc::wrapped::docker network create "${args[@]}" "$name"
}

docker::network::inspect::label() {
  local id="$1"
  local label="$2"

  dc::argument::check id "$DC_TYPE_STRING" || return
  dc::argument::check label "$DC_TYPE_STRING" || return

  docker::network::inspect "$id" | jq -rc ".[0].Labels | select(.\"$label\" != null).\"$label\""
}

docker::network::inspect::containers() {
  local id="${1:-}"

  dc::argument::check id "$DC_TYPE_STRING" || return

  docker::network::inspect "$id" | jq -rc ".[0].Containers | keys[]"
}

###############################################################################
# Image
###############################################################################

docker::image::lookup() {
  local name="$1"
  local tag="${2:-}"
  local digest="${3:-}"
  local id

  dc::argument::check name "$DC_TYPE_STRING" || return

  # XXX get part of regander in here (grammar, specifically)
  if [ "$digest" ]; then
    dc::argument::check digest "$DC_TYPE_STRING" || return
    name="$name@$digest"
  else
    dc::argument::check tag "$DC_TYPE_STRING" || return
    name="$name:$tag"
  fi

  id="$(dc::wrapped::docker images -q "$name")"
  [ "$id" ] || {
    dc::error::detail::set "Image $name does not exist"
    return "$ERROR_DOCKER_NO_SUCH_OBJECT"
  }
  printf "%s" "$id"
}

docker::image::inspect() {
  local name="$1"
  local tag="${2:-}"
  local digest="${3:-}"

  dc::argument::check name "$DC_TYPE_STRING" || return

  if [ "$digest" ]; then
    dc::argument::check digest "$DC_TYPE_STRING" || return
    name="$name@$digest"
  else
    dc::argument::check tag "$DC_TYPE_STRING" || return
    name="$name:$tag"
  fi

  docker::inspect "$name"
}

docker::image::remove(){
  local name="$1"
  local tag="${2:-}"
  local digest="${3:-}"

  dc::argument::check name "$DC_TYPE_STRING" || return

  if [ "$digest" ]; then
    dc::argument::check digest "$DC_TYPE_STRING" || return
    name="$name@$digest"
  else
    dc::argument::check tag "$DC_TYPE_STRING" || return
    name="$name:$tag"
  fi

  dc::wrapped::docker rmi "$name" > /dev/null
}


docker::image::pull() {
  local name="$1"
  local tag="${2:-}"
  local digest="${3:-}"

  dc::argument::check name "$DC_TYPE_STRING" || return

  if [ "$digest" ]; then
    dc::argument::check digest "$DC_TYPE_STRING" || return
    name="$name@$digest"
  else
    dc::argument::check tag "$DC_TYPE_STRING" || return
    name="$name:$tag"
  fi

  dc::wrapped::docker pull "$name" > /dev/null || {
    dc::error::detail::set "Image $name does not exist"
    return "$ERROR_DOCKER_NO_SUCH_OBJECT"
  }
}

docker::image::digest() {
  local name="$1"
  local tag="${2:-}"

  local result

  dc::argument::check name "$DC_TYPE_STRING" || return
  dc::argument::check tag "$DC_TYPE_STRING" || return

  name="$name:$tag"

  result="$(dc::wrapped::docker inspect "$name" | jq -rc ".[].RepoDigests[0]")" || {
    dc::error::detail::set "Image $name does not exist"
    return "$ERROR_DOCKER_NO_SUCH_OBJECT"
  }

  printf "%s" "${result##*@}"
}

docker::image::id() {
  local name="$1"
  local tag="${2:-}"
  local digest="${3:-}"

  dc::argument::check name "$DC_TYPE_STRING" || return

  if [ "$digest" ]; then
    dc::argument::check digest "$DC_TYPE_STRING" || return
    name="$name@$digest"
  else
    dc::argument::check tag "$DC_TYPE_STRING" || return
    name="$name:$tag"
  fi

  dc::wrapped::docker inspect "$name" | jq -rc ".[].Id" || {
    dc::error::detail::set "Image $name does not exist"
    return "$ERROR_DOCKER_NO_SUCH_OBJECT"
  }
}

#docker::registry::digest() {
#  local name="$1"
#  local tag="${2:-}"
#  printf "" | module::run regander -s manifest HEAD "$name" "$tag" | jq -rc ".digest"
#}
