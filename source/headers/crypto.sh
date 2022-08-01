#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

# Crypto
dc::internal::error::register CRYPTO_SHASUM_WRONG_ALGORITHM
dc::internal::error::register CRYPTO_SHASUM_FILE_ERROR
dc::internal::error::register CRYPTO_SSL_INVALID_KEY
dc::internal::error::register CRYPTO_SSL_WRONG_PASSWORD
dc::internal::error::register CRYPTO_SSL_WRONG_ARGUMENTS
dc::internal::error::register CRYPTO_SHASUM_VERIFY_ERROR
dc::internal::error::register CRYPTO_PEM_NO_SUCH_HEADER

# shellcheck disable=SC2034
readonly DC_CRYPTO_SHASUM_1=1
# shellcheck disable=SC2034
readonly DC_CRYPTO_SHASUM_224=224
# shellcheck disable=SC2034
# shellcheck disable=SC2034
readonly DC_CRYPTO_SHASUM_256=256
# shellcheck disable=SC2034
readonly DC_CRYPTO_SHASUM_384=384
# shellcheck disable=SC2034
readonly DC_CRYPTO_SHASUM_512=512
# shellcheck disable=SC2034
readonly DC_CRYPTO_SHASUM_512224=512224
# shellcheck disable=SC2034
readonly DC_CRYPTO_SHASUM_512256=512256
