#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

dc::internal::error::register DOCKER_WRONG_COMMAND
dc::internal::error::register DOCKER_WRONG_SYNTAX
dc::internal::error::register DOCKER_NO_SUCH_OBJECT
dc::internal::error::register DOCKER_MISSING_PLUGIN
