#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

dc::wrapped::shasum(){
  # XXX bash5 makes this fail
  local _
  _="$(dc::require shasum)" || return
  # dc::require shasum || return

  local err

  exec 3>&1
  if ! err="$(shasum "$@" 2>&1 1>&3)"; then
    exec 3>&-
    if printf "%s" "$err" | dc::wrapped::grep -q "(invalid for option a|Unrecognized algorithm)"; then
      return "$ERROR_CRYPTO_SHASUM_WRONG_ALGORITHM"
    fi
    if [ ! "$err" ]; then
      return "$ERROR_CRYPTO_SHASUM_FILE_ERROR"
    fi
    dc::error::detail::set "$err"
    return "$ERROR_BINARY_UNKNOWN_ERROR"
  fi
  exec 3>&-
}

# ASN1: interface description - https://en.wikipedia.org/wiki/Abstract_Syntax_Notation_One
# DER: binary encoding method - https://en.wikipedia.org/wiki/X.690#DER_encoding
# PEM: base64 + headers representation of a binary message - https://en.wikipedia.org/wiki/Privacy-Enhanced_Mail

# Analyze key: openssl asn1parse -i -dump < root-key.pem
# More details: openssl ec -noout -text -in test-key.pem
# Analyze CSR: openssl req -in test.csr -noout -text

# Key manipulation
dc::wrapped::openssl(){
  local com=openssl
  local err
  local _

  command -v openssl > /dev/null || com=libressl
  # XXX bash5 makes this fail by consuming the fd - wtf
  _="$(dc::require $com 1.0 version)" || return
  # dc::require $com 1.0 version || return

  exec 3>&1
  if ! err="$($com "$@" 2>&1 1>&3)"; then
    exec 3>&-

    # Known error conditions
    printf "%s" "$err" | dc::wrapped::grep -q "(Error reading password from BIO|routines:(PEM_do_header|CRYPTO_internal):bad decrypt)" \
      && return "$ERROR_CRYPTO_SSL_WRONG_PASSWORD"
    printf "%s" "$err" | dc::wrapped::grep -q "(:string too short:|end of string encountered while processing type of subject)" \
      && return "$ERROR_CRYPTO_SSL_WRONG_ARGUMENTS"
    printf "%s" "$err" | dc::wrapped::grep -q "(:no start line:|Could not find private key|Could not read private key|Could not read key from)" \
      && return "$ERROR_CRYPTO_SSL_INVALID_KEY"

    # Generic unspecified error
    dc::error::detail::set "$err"
    return "$ERROR_BINARY_UNKNOWN_ERROR"
  fi

  # With openssl 1.1 you can create a CSR with no data as subject: /C=/ST=/L=/O=/OU=/CN=/emailAddress=
  # This here is just to safe-guard against it - mostly for test consistency...
  [ "${*: -1}" == "/C=/ST=/L=/O=/OU=/CN=/emailAddress=" ] && return "$ERROR_CRYPTO_SSL_WRONG_ARGUMENTS"

  exec 3>&-
  # routines:CRYPTO_internal:bad password read <- errr, not sure how I produced that, but that was the way to prevent openssl from prompting for a password
}

dc::crypto::shasum::compute(){
  local fd="${1:-/dev/stdin}"
  local type="${2:-$DC_CRYPTO_SHASUM_512256}"
  local prefixed="${3:-}"
  local digest

  # For some versions, hashing a directory does not error out like it should
  [ ! -d "$fd" ] || return "$ERROR_BINARY_UNKNOWN_ERROR"

  digest="$(dc::wrapped::shasum -a "$type" "$fd")" || return
  [ ! "$prefixed" ] || printf "sha%s:" "$type"
  printf "%s" "${digest%% *}"
}

dc::crypto::shasum::verify(){
  local expected="$1"
  local fd="${2:-/dev/stdin}"
  local type="${3:-$DC_CRYPTO_SHASUM_512256}"

  # For some versions, hashing a directory does not error out like it should
  [ ! -d "$fd" ] || return "$ERROR_BINARY_UNKNOWN_ERROR"

  # Get the type from the expectation string if it's there, or default to arg 3 if provided, fallback to 512256
  # if dc::wrapped::grep -q "^sha[0-9]+:" <(printf "%s" "$expected"); then
  # if dc::wrapped::grep -q "^sha[0-9]+:" <<<"$expected"; then
  if dc::internal::securewrap grep -Eq "^sha[0-9]+:" <<<"$expected"; then
    type="${expected%:*}"
    type="${type#*sha}"
  fi

  digest="$(dc::wrapped::shasum -a "$type" "$fd")" || return

  if [ "${digest%% *}" != "${expected#*:}" ]; then
    dc::error::detail::set "was ${digest%% *} (expected: ${expected#*:})"
    return "$ERROR_CRYPTO_SHASUM_VERIFY_ERROR"
  fi
}

dc::crypto::ec::new(){
  dc::wrapped::openssl ecparam -name prime256v1 -param_enc named_curve -genkey -noout
}

# shellcheck disable=SC2120
dc::crypto::ec::public(){
  local fd="${1:-/dev/stdin}"
  dc::wrapped::openssl ec -in "$fd" -pubout
}

dc::crypto::ec::encrypt(){
  local password="$1"
  local fd="${2:-/dev/stdin}"

  # XXX investigate upgrades to cipher
  dc::wrapped::openssl ec -in "$fd" -aes256 -passout file:<( printf "%s" "$password" )
}

dc::crypto::ec::decrypt(){
  local password="$1"
  local fd="${2:-/dev/stdin}"

  dc::wrapped::openssl ec -in "$fd" -passin file:<( printf "%s" "$password" )
}

dc::crypto::ec::to::pkcs8(){
  local password="$1"
  local fd="${2:-/dev/stdin}"

  dc::wrapped::openssl pkcs8 -topk8 -in "$fd" -passout file:<(printf "%s" "$password")
}

dc::crypto::pkcs8::to::ec(){
  local password="$1"
  local fd="${2:-/dev/stdin}"

  dc::wrapped::openssl ec -in "$fd" -passin file:<(printf "%s" "$password")
}

dc::crypto::csr::new(){
  local country="${1:-}"
  local state="${2:-}"
  local city="${3:-}"
  local organization="${4:-}"
  local organizationUnit="${5:-}"
  local name="${6:-}"
  local email="${7:-}"

  [ ! "$email" ] || dc::argument::check email "$DC_TYPE_EMAIL" || return

  dc::wrapped::openssl req -new -sha256 -key /dev/stdin -subj "/C=$country/ST=$state/L=$city/O=$organization/OU=$organizationUnit/CN=$name/emailAddress=$email"
}

# PEM headers manipulation
dc::crypto::pem::headers::strip(){
  local fd=${1:-/dev/stdin}

  dc::wrapped::grep -v "^([a-zA-Z]+:.*)?$" "$fd"
}

dc::crypto::pem::headers::has(){
  local key="$1"
  local value="${2:-.*}"
  local fd="${3:-/dev/stdin}"

  dc::argument::check key "$DC_TYPE_ALPHANUM" || return

  dc::wrapped::grep -q "^$key: $value$" "$fd" \
    || { dc::error::detail::set "$key: $value" && return "$ERROR_CRYPTO_PEM_NO_SUCH_HEADER"; }
}

dc::crypto::pem::headers::get(){
  local key="$1"
  local fd="${2:-/dev/stdin}"
  local value

  dc::crypto::pem::headers::has "$key" "$fd" || return

  while IFS= read -r value || [ "$value" ]; do
    printf "%s\n" "${value#* }"
  done < <(dc::wrapped::grep "^$key:" "$fd")
}

dc::crypto::pem::headers::set(){
  local key="$1"
  local value="$2"
  local fd="${3:-/dev/stdin}"

  local line

  dc::argument::check key "$DC_TYPE_ALPHANUM" || return

  while IFS= read -r line || [ "$line" ]; do
    printf "%s\n" "$line"
    # XXX this could fail if we are not dealing with a valid pem file
    if [[ "$line" =~ ^-----BEGIN ]]; then
      printf "%s: %s\n" "$key" "$value"
    fi
  done < "$fd"
}

dc::crypto::pem::headers::delete(){
  local key="$1"
  local fd="${2:-/dev/stdin}"

  dc::crypto::pem::headers::has "$key" "$fd" || return

  dc::wrapped::grep -v "^$key:" "$fd"
}
