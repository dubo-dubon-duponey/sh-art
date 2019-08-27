#!/usr/bin/env bash

dc::wrapped::shasum(){
  dc::require shasum || return

  local err

  exec 3>&1
  if ! err="$(shasum "$@" 2>&1 1>&3)"; then
    exec 3>&-
    if printf "%s" "$err" | dc::internal::grep -q "(invalid for option a|Unrecognized algorithm)"; then
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
  dc::require openssl version 1.0 || return

  local err

  exec 3>&1
  if ! err="$(openssl "$@" 2>&1 1>&3)"; then
    exec 3>&-

    # Known error conditions
    printf "%s" "$err" | dc::internal::grep -q ":no start line:" \
      && return "$ERROR_CRYPTO_SSL_INVALID_KEY"
    printf "%s" "$err" | dc::internal::grep -q "(Error reading password from BIO|routines:(PEM_do_header|CRYPTO_internal):bad decrypt)" \
      && return "$ERROR_CRYPTO_SSL_WRONG_PASSWORD"
    printf "%s" "$err" | dc::internal::grep -q "(:string too short:|end of string encountered while processing type of subject)" \
      && return "$ERROR_CRYPTO_SSL_WRONG_ARGUMENTS"

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

dc::wrapped::base64d(){
  dc::require base64 || return

  case "$(uname)" in
    Darwin)
      base64 -D
    ;;
    *)
      base64 -d
    ;;
  esac
}

dc::wrapped::iconv(){
  dc::require iconv || return

  iconv "$@" 2>/dev/null \
    || { dc::error::detail::set "iconv" && return "$ERROR_BINARY_UNKNOWN_ERROR"; }
}

dc::wrapped::uchardet(){
  dc::require uchardet || return

  uchardet "$@" 2>/dev/null \
    || { dc::error::detail::set "uchardet" && return "$ERROR_BINARY_UNKNOWN_ERROR"; }
}
