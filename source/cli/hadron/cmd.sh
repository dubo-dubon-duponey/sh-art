#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

# shellcheck disable=SC2034
readonly CLI_DESC="fast and simple repalcement for terraform-docker-provider"

dc::commander::initialize
#dc::commander::declare::flag preserve "^$" "do not delete intermediary files" optional p
#dc::commander::declare::arg 1 "$DC_TYPE_STRING" "image" "the path to the png image to use"
dc::commander::boot

hadron::init

hadron::connect apo 10.0.4.222

hadron::network <<<'{
  "name": "test-net-hadron-122",
  "driver": "bridge",
  "attachable": false,
  "internal": false,
  "ipv6": false,
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

hadron::container <<<'{
  "name": "mycno",
  "image": "dubodubonduponey/testing",
  "network": ["test-net-hadron-122"],
  "read_only": false,
  "command": "sleep 36001"
}'

hadron::deploy

hadron::connect apo 10.0.4.222

dc::docker::client::network::list json "label=org.hadron.plan.sha" | jq .
dc::docker::client::container::list all json "label=org.hadron.plan.sha" | jq .


exit






hadron::container <<<'{
  "name": "mycn2o",
  "image": "nginx",
  "network": ["test-net-hadron-12"],
  "read_only": false,
  "command": "sleep 3600"
}'






