#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

# XXX validate and test this
# Network
readonly _dc_ip="[0-9]{1,3}[.][0-9]{1,3}[.][0-9]{1,3}[.][0-9]{1,3}"
readonly _dc_domain="(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?.)+[a-z0-9][a-z0-9-]{0,61}[a-z0-9]"
# shellcheck disable=SC2034
readonly DC_TYPE_IPV4="^$_dc_ip$"
# XXX 1-32
# shellcheck disable=SC2034
readonly DC_TYPE_CIDR="^[0-9]{1,3}[.][0-9]{1,3}[.][0-9]{1,3}[.][0-9]{1,3}/[0-9]{1,2}$"
# shellcheck disable=SC2034
readonly DC_TYPE_USER="^[a-zA-Z0-9_.~!$&'()*+,;=:-]+$"
# shellcheck disable=SC2034
readonly DC_TYPE_DOMAIN="^$_dc_domain$"
# shellcheck disable=SC2034
readonly DC_TYPE_DOMAIN_OR_IP="^(?:$_dc_domain|$_dc_ip)$"
