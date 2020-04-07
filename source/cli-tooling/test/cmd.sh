#!/usr/bin/env bash

true

# shellcheck disable=SC2034
readonly CLI_DESC="basic unit and integration testing framework"

dc::commander::initialize
dc::commander::declare::arg 1 "$DC_TYPE_STRING" "source" "Test file"
dc::commander::boot

dc::fs::isfile "${DC_ARG_1:-}"
