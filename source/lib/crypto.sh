#!/usr/bin/env bash

dc::crypto::shasum::compute(){
  local fd="${1:-/dev/stdin}"
  local type="${2:-$DC_CRYPTO_SHASUM_512256}"
  local prefixed="$3"
  local digest

  digest="$(dc::wrapped::shasum -a "$type" "$fd")" || return
  [ ! "$prefixed" ] || printf "sha%s:" "$type"
  printf "%s" "${digest%% *}"
}

dc::crypto::shasum::verify(){
  local expected="$1"
  local fd="${2:-/dev/stdin}"
  local type="${3:-$DC_CRYPTO_SHASUM_512256}"

  # Get the type from the expectation string if it's there, or default to arg 3 if provided, fallback to 512256
  #if dc::internal::grep -q "^sha[0-9]+:" <(printf "%s" "$expected"); then
  if printf "%s" "$expected" | dc::internal::grep -q "^sha[0-9]+:"; then
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
  local country="$1"
  local state="$2"
  local city="$3"
  local organization="$4"
  local organizationUnit="$5"
  local name="$6"
  # XXX argument validation here? New type for email?
  local email="$7"

  dc::argument::check email "$DC_TYPE_EMAIL"

  dc::wrapped::openssl req -new -sha256 -key /dev/stdin -subj "/C=$country/ST=$state/L=$city/O=$organization/OU=$organizationUnit/CN=$name/emailAddress=$email"
}

# PEM headers manipulation
dc::crypto::pem::headers::strip(){
  local fd=${1:-/dev/stdin}

  dc::internal::grep -v "^([a-zA-Z]+:.*)?$" "$fd"
}

dc::crypto::pem::headers::has(){
  local key="$1"
  local value="${2:-.*}"
  local fd="${3:-/dev/stdin}"

  dc::argument::check key "$DC_TYPE_ALPHANUM"

  dc::internal::grep -q "^$key: $value$" "$fd" \
    || { dc::error::detail::set "$key: $value" && return "$ERROR_CRYPTO_PEM_NO_SUCH_HEADER"; }
}

dc::crypto::pem::headers::get(){
  local key="$1"
  local fd="${2:-/dev/stdin}"
  local value

  dc::crypto::pem::headers::has "$key" "$fd" || return

  while IFS= read -r value || [ "$value" ]; do
    printf "%s\n" "${value#* }"
  done < <(dc::internal::grep "^$key:" "$fd")
}

dc::crypto::pem::headers::set(){
  local key="$1"
  local value="$2"
  local fd="${3:-/dev/stdin}"

  local line

  dc::argument::check key "$DC_TYPE_ALPHANUM"

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

  dc::internal::grep -v "^$key:" "$fd"
}
