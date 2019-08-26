#!/usr/bin/env bash

true

# shellcheck disable=SC2034
readonly DC_TYPE_INTEGER="^-?[0-9]+$"
# shellcheck disable=SC2034
readonly DC_TYPE_UNSIGNED="^[0-9]+$"
# shellcheck disable=SC2034
readonly DC_TYPE_FLOAT="^-?[0-9]+([.][0-9]+)?$"
# shellcheck disable=SC2034
readonly DC_TYPE_BOOLEAN="^(true|false)$"

# https://pubs.opengroup.org/onlinepubs/000095399/basedefs/xbd_chap08.html
# Not really compliant with https://en.wikipedia.org/wiki/Portable_character_set minus "=" and NUL, but then good enough
# shellcheck disable=SC2034
readonly DC_TYPE_VARIABLE="^[a-zA-Z_]{1,}[a-zA-Z0-9_]{0,}$"

# shellcheck disable=SC2034
readonly DC_TYPE_ALPHANUM="^[a-zA-Z0-9]$"
# shellcheck disable=SC2034
readonly DC_TYPE_HEX="^[a-fA-Z0-9]$"
