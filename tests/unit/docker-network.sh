#!/usr/bin/env bash

. source/headers/docker.sh
. source/headers/types.sh
. source/lib/docker.sh

testDockerNetworkLookup() {
  local result
  local exitcode

  [ "$HOME" != /home/dckr ] || startSkipping

  exitcode=0
  docker::network::lookup >/dev/null || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} must provide network name" "ARGUMENT_INVALID" "$(dc::error::lookup $exitcode)"

  exitcode=0
  docker::network::lookup "nonexistentbs" >/dev/null || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} non existent network" "DOCKER_NO_SUCH_OBJECT" "$(dc::error::lookup $exitcode)"

  exitcode=0
  result="$(docker::network::lookup "bridge")" || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} bridge network exist" "NO_ERROR" "$(dc::error::lookup $exitcode)"
  dc-tools::assert::notnull "${FUNCNAME[0]} bridge network id not null" "$result"

  [ "$HOME" != /home/dckr ] || endSkipping
}

testDockerNetworkInspect() {
  local result
  local exitcode

  [ "$HOME" != /home/dckr ] || startSkipping

  exitcode=0
  docker::network::inspect >/dev/null || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} must provide network id" "ARGUMENT_INVALID" "$(dc::error::lookup $exitcode)"

  exitcode=0
  docker::network::inspect nonexistentbs >/dev/null || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} non existent network" "DOCKER_NO_SUCH_OBJECT" "$(dc::error::lookup $exitcode)"

  exitcode=0
  result="$(docker::network::inspect "bridge" | jq -rc .[0].Name)" || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} bridge network has data" "NO_ERROR" "$(dc::error::lookup $exitcode)"
  dc-tools::assert::equal "${FUNCNAME[0]} bridge name is bridge" "bridge" "$result"

  [ "$HOME" != /home/dckr ] || endSkipping
}

testDockerNetworkCreateFail() {
  local exitcode

  [ "$HOME" != /home/dckr ] || startSkipping

  exitcode=0
  docker::network::create <(
    cat <<EOF
	{
	  "driver": "bridge",
	  "attachable": false,
	  "internal": false,
	  "ipv6": false
	}
EOF
  ) || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} missing name" "ARGUMENT_INVALID" "$(dc::error::lookup $exitcode)"

  exitcode=0
  docker::network::create <(
    cat <<EOF
	{
	  "name": "",
	  "driver": "bridge",
	  "attachable": false,
	  "internal": false,
	  "ipv6": false
	}
EOF
  ) || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} missing name" "ARGUMENT_INVALID" "$(dc::error::lookup $exitcode)"

  exitcode=0
  docker::network::create <(
    cat <<EOF
	{
  	"name": "network-name",
	  "attachable": false,
	  "internal": false,
	  "ipv6": false
	}
EOF
  ) || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} missing driver" "ARGUMENT_INVALID" "$(dc::error::lookup $exitcode)"

  exitcode=0
  docker::network::create <(
    cat <<EOF
	{
  	"name": "network-name",
  	"driver": "",
	  "attachable": false,
	  "internal": false,
	  "ipv6": false
	}
EOF
  ) || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} missing driver" "ARGUMENT_INVALID" "$(dc::error::lookup $exitcode)"

  exitcode=0
  docker::network::create <(
    cat <<EOF
	{
  	"name": "network-name",
	  "driver": "invalid-driver",
	  "attachable": false,
	  "internal": false,
	  "ipv6": false
	}
EOF
  ) || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} invalid driver" "DOCKER_MISSING_PLUGIN" "$(dc::error::lookup $exitcode)"

  exitcode=0
  docker::network::create <(
    cat <<EOF
	{
  	"name": "network-name",
	  "driver": "bridge",
	  "attachable": "wrong",
	  "internal": false,
	  "ipv6": false
	}
EOF
  ) || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} wrong attachable" "ARGUMENT_INVALID" "$(dc::error::lookup $exitcode)"

  exitcode=0
  docker::network::create <(
    cat <<EOF
	{
  	"name": "network-name",
	  "driver": "bridge",
	  "internal": false,
	  "ipv6": false
	}
EOF
  ) || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} wrong attachable" "ARGUMENT_INVALID" "$(dc::error::lookup $exitcode)"

  exitcode=0
  docker::network::create <(
    cat <<EOF
	{
  	"name": "network-name",
	  "driver": "bridge",
	  "attachable": false,
	  "internal": "wrong",
	  "ipv6": false
	}
EOF
  ) || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} wrong internal" "ARGUMENT_INVALID" "$(dc::error::lookup $exitcode)"

  exitcode=0
  docker::network::create <(
    cat <<EOF
	{
  	"name": "network-name",
	  "driver": "bridge",
	  "attachable": false,
	  "ipv6": false
	}
EOF
  ) || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} wrong internal" "ARGUMENT_INVALID" "$(dc::error::lookup $exitcode)"

  exitcode=0
  docker::network::create <(
    cat <<EOF
	{
  	"name": "network-name",
	  "driver": "bridge",
	  "attachable": false,
	  "internal": false,
	  "ipv6": "wrong"
	}
EOF
  ) || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} wrong ipv6" "ARGUMENT_INVALID" "$(dc::error::lookup $exitcode)"

  exitcode=0
  docker::network::create <(
    cat <<EOF
	{
  	"name": "network-name",
	  "driver": "bridge",
	  "attachable": false,
	  "internal": false
	}
EOF
  ) || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} wrong ipv6" "ARGUMENT_INVALID" "$(dc::error::lookup $exitcode)"

  exitcode=0
  docker::network::create <(
    cat <<EOF
	{
  	"name": "network-name",
	  "driver": "bridge",
	  "attachable": false,
	  "internal": false,
	  "ipv6": false,
	  "gateway": "1.2.3"
	}
EOF
  ) || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} wrong gateway" "ARGUMENT_INVALID" "$(dc::error::lookup $exitcode)"

  exitcode=0
  docker::network::create <(
    cat <<EOF
	{
  	"name": "network-name",
	  "driver": "bridge",
	  "attachable": false,
	  "internal": false,
	  "ipv6": false,
	  "subnet": "1.2.3.4/255"
	}
EOF
  ) || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} wrong subnet" "ARGUMENT_INVALID" "$(dc::error::lookup $exitcode)"

  exitcode=0
  docker::network::create <(
    cat <<EOF
	{
  	"name": "network-name",
	  "driver": "bridge",
	  "attachable": false,
	  "internal": false,
	  "ipv6": false,
	  "subnet": "1.2.3.4/255"
	}
EOF
  ) || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} wrong ip range" "ARGUMENT_INVALID" "$(dc::error::lookup $exitcode)"

  [ "$HOME" != /home/dckr ] || endSkipping
}

testDockerNetworkRm() {
  local exitcode

  [ "$HOME" != /home/dckr ] || startSkipping

  exitcode=0
  docker::network::remove || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} no id" "ARGUMENT_INVALID" "$(dc::error::lookup $exitcode)"

  exitcode=0
  docker::network::remove nonexistentbs || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} non existent" "DOCKER_NO_SUCH_OBJECT" "$(dc::error::lookup $exitcode)"

  [ "$HOME" != /home/dckr ] || endSkipping
}

testDockerNetworkCreateSuccess() {
  local result
  local exitcode

  [ "$HOME" != /home/dckr ] || startSkipping

  exitcode=0
  docker network rm success-network 2>/dev/null || true

  exitcode=0
  result=$(docker::network::create <(
    cat <<EOF
	{
  	"name": "success-network",
	  "driver": "bridge",
	  "attachable": false,
	  "internal": true,
	  "ipv6": false,
	  "labels": {
	    "foo": "I'm foo",
	    "bar": "I'm bar"
	  }
	}
EOF
  )) || exitcode=$?

  dc-tools::assert::equal "${FUNCNAME[0]} succesfully created network" "NO_ERROR" "$(dc::error::lookup $exitcode)"
  dc-tools::assert::notnull "${FUNCNAME[0]} created network id not null" "$result"

  # Now, inspect
  local output
  output="$(docker inspect "$result")" || true

  dc-tools::assert::equal "${FUNCNAME[0]} created network name matches" "success-network" "$(printf "%s" "$output" | jq -rc '.[0].Name')"
  dc-tools::assert::equal "${FUNCNAME[0]} created network attachable" "false" "$(printf "%s" "$output" | jq -rc '.[0].Attachable')"
  dc-tools::assert::equal "${FUNCNAME[0]} created network internal" "true" "$(printf "%s" "$output" | jq -rc '.[0].Internal')"
  dc-tools::assert::equal "${FUNCNAME[0]} created network ipv6" "false" "$(printf "%s" "$output" | jq -rc '.[0].EnableIPv6')"
  dc-tools::assert::equal "${FUNCNAME[0]} created network labels" "I'm bar" "$(printf "%s" "$output" | jq -rc '.[0].Labels.bar')"

  output="$(docker::network::inspect::label "$result" bar)" || true
  dc-tools::assert::equal "${FUNCNAME[0]} created network labels with helper" "I'm bar" "$output"

  output="$(docker::network::inspect::containers "$result")" || true
  dc-tools::assert::equal "${FUNCNAME[0]} created network containers list" "" "$output"

  local id
  id="$(docker run -d --net success-network --name testing-network-attach busybox)" || true

  output="$(docker::network::inspect::containers "$result")" || true
  dc-tools::assert::equal "${FUNCNAME[0]} created network attached containers" "$id" "$output"

  docker rm -f "$id" > /dev/null || true

  exitcode=0
  docker::network::remove "$result" > /dev/null || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} succesfully removed network by id" "NO_ERROR" "$(dc::error::lookup $exitcode)"

  [ "$HOME" != /home/dckr ] || endSkipping
}
