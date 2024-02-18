#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

# Error registration
# Domain resolution failed
dc::internal::error::register SSH_CLIENT_RESOLUTION
# Connection refused
dc::internal::error::register SSH_CLIENT_CONNECTION
# Authentication failed
dc::internal::error::register SSH_CLIENT_AUTHENTICATION
