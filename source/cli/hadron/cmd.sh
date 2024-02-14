#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

# shellcheck disable=SC2034
readonly CLI_DESC="fast and simple repalcement for terraform-docker-provider"

dc::commander::initialize
#dc::commander::declare::flag preserve "^$" "do not delete intermediary files" optional p
#dc::commander::declare::arg 1 "$DC_TYPE_STRING" "image" "the path to the png image to use"
dc::commander::boot

hadron::init


hadron::connect apo dacodac.local

hadron::network <<<'{
  "name": "test-net-hadron-1",
  "driver": "bridge",
  "attachable": true,
  "internal": false,
  "ipv6": true,
  "subnet": [
    "fd01:dead:beef::/48",
    "192.168.42.0/24"
  ],
  "gateway": null,
  "ip_range": null,
  "aux_address": null,
  "parent": null,
  "ipvlan_mode": null
}'

hadron::network <<<'{
  "name": "test-net-hadron-2",
  "driver": "bridge",
  "attachable": true,
  "internal": false,
  "ipv6": false,
  "subnet": null,
  "gateway": null,
  "ip_range": null,
  "aux_address": null,
  "parent": null,
  "ipvlan_mode": null
}'

hadron::network <<<'{
  "name": "test-net-hadron-4",
  "driver": "bridge",
  "attachable": false,
  "internal": false,
  "ipv6": false,
  "subnet": null,
  "gateway": null,
  "ip_range": null,
  "aux_address": null,
  "parent": null,
  "ipvlan_mode": null
}'

hadron::deploy

