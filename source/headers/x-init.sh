#!/usr/bin/env bash

dc::error::handler(){
  local exit="$1"
  local detail="$2"
  local command="$3"
  local lineno="$4"

  dc::logger::error "[CONSOLE HANDLER] Exit code:       $exit"
  dc::logger::error "[CONSOLE HANDLER]      condition:  $(dc::error::lookup "$exit")"
  dc::logger::error "[CONSOLE HANDLER]      detail:     $detail"
  dc::logger::error "[CONSOLE HANDLER]      command:    $command"
  dc::logger::error "[CONSOLE HANDLER]      line:       $lineno"

  cat -n "$0" |  grep -E "^\s+$((lineno - 2))\s"
  cat -n "$0" |  grep -E "^\s+$((lineno - 1))\s"
  # Coloring
  cat -n "$0" |  grep -E "^\s+$((lineno))\s"
  cat -n "$0" |  grep -E "^\s+$((lineno + 1))\s"
  cat -n "$0" |  grep -E "^\s+$((lineno + 2))\s"

  case "$exit" in
    # https://www.tldp.org/LDP/abs/html/exitcodes.html
    1)
      dc::logger::error "Generic script failure"
    ;;
    2)
      dc::logger::error "Misused shell builtin is a likely explanation"
    ;;
    126)
      dc::logger::error "Permission issue, or cannot execute command"
    ;;
    127)
      dc::logger::error "Missing binary or a typo in a command name"
    ;;
    # none of these two will be triggered with bash apparently
    128)
      dc::logger::error "XXXSHOULDNEVERHAPPENXXX"
      dc::logger::error "XXXSHOULDNEVERHAPPENXXX Invalid argument to exit"
    ;;
    255)
      dc::logger::error "XXXSHOULDNEVERHAPPENXXX"
      dc::logger::error "Additionally, the exit code we got ($exit) is out of range (0-255). We will exit 1."
    ;;

    ##################################
    # Basic core: none of that should ever happen uncaught. Caller should always catch and do something useful with it.
    "$ERROR_BINARY_UNKNOWN_ERROR")
      dc::logger::error "UNCAUGHT EXCEPTION: generic binary failure $detail"
    ;;
    "$ERROR_GREP_NO_MATCH")
      dc::logger::error "UNCAUGHT EXCEPTION: grep not matching"
    ;;

    ##################################
    # Basic core: these could bubble up

    # Typical filesystem errors: file does not exist, is unreadable, or permission denied
    "$ERROR_FILESYSTEM")
      dc::logger::error "Verify that the provided path ($detail) exist and/or is writable"
    ;;


    # This is a lazy catch-all for non specific problems.
    "$ERROR_GENERIC_FAILURE")
      dc::logger::error "Script failed: $detail"
    ;;
    # Denotes that something is not implemented or unsupported on the given platform
    "$ERROR_UNSUPPORTED")
      dc::logger::error "The requested operation is not supported: $detail"
    ;;
    # Some requirements are missing
    "$ERROR_REQUIREMENT_MISSING")
      dc::logger::error "Sorry, you need $detail for this to work."
    ;;
    # Provided argument doesn't validate
    "$ERROR_ARGUMENT_INVALID")
      dc::logger::error "Provided argument $detail is invalid"
    ;;
    # We waited for the user for too long
    "$ERROR_ARGUMENT_TIMEOUT")
      dc::logger::error "Timed-out waiting for user input after $detail seconds"
    ;;
    # Something is amiss
    "$ERROR_ARGUMENT_MISSING")
      dc::logger::error "Required argument $detail is missing"
    ;;

    ##################################
    # Lib: these should be caught
    "$ERROR_CRYPTO_SHASUM_WRONG_ALGORITHM")
      dc::logger::error "UNCAUGHT EXCEPTION: shasum wrong algorithm used"
    ;;
    "$ERROR_CRYPTO_SHASUM_FILE_ERROR")
      dc::logger::error "UNCAUGHT EXCEPTION: failed to read file"
    ;;
    "$ERROR_CRYPTO_SSL_INVALID_KEY")
      dc::logger::error "UNCAUGHT EXCEPTION: invalid key"
    ;;
    "$ERROR_CRYPTO_SSL_WRONG_PASSWORD")
      dc::logger::error "UNCAUGHT EXCEPTION: wrong password"
    ;;
    "$ERROR_CRYPTO_SSL_WRONG_ARGUMENTS")
      dc::logger::error "UNCAUGHT EXCEPTION: wrong arguments"
    ;;

    # Crypto
    "$ERROR_CRYPTO_SHASUM_VERIFY_ERROR")
      dc::logger::error "Shasum failed verification: $detail"
    ;;
    "$ERROR_CRYPTO_PEM_NO_SUCH_HEADER")
      dc::logger::error "Pem file has no such header: $detail"
    ;;
    # Encoding
    "$ERROR_ENCODING_CONVERSION_FAIL")
      dc::logger::error "Failed to convert file $detail"
    ;;
    "$ERROR_ENCODING_UNKNOWN")
      dc::logger::error "Failed to guess encoding for $detail"
    ;;
    # HTTP
    "$ERROR_CURL_DNS_FAILED")
      dc::logger::error "Failed to resolve domain name $detail"
    ;;
    "$ERROR_CURL_CONNECTION_FAILED")
      dc::logger::error "Failed to connect to server at $detail"
    ;;

    *)
      if [ "$exit" -lt 129 ] || [ "$exit" -gt 143 ]; then
        dc::logger::error "UNCAUGHT EXCEPTION: $exit $(dc::error::lookup "$exit"): $detail"
      fi
    ;;
  esac

  dc::logger::debug "Build information" \
    "DC_VERSION: $DC_VERSION" \
    "DC_REVISION: $DC_REVISION" \
    "DC_BUILD_DATE: $DC_BUILD_DATE" \
    "DC_BUILD_PLATFORM: $DC_BUILD_PLATFORM" \
    "DC_LIB_VERSION: $DC_LIB_VERSION" \
    "DC_LIB_REVISION: $DC_LIB_REVISION" \
    "DC_LIB_BUILD_DATE: $DC_LIB_BUILD_DATE" \
    "DC_LIB_BUILD_PLATFORM: $DC_LIB_BUILD_PLATFORM"

  dc::logger::debug "Runtime information" \
    "uname: $(uname -a || true)" \
    "bash: $(command -v bash || true) $(dc::internal::version::get bash || true)" \
    "grep: $(command -v grep || true) $(dc::internal::version::get grep || true)" \
    "ps: $(command -v ps || true)" \
    "[: $(command -v \[ || true)" \
    "tput: $(command -v tput || true)" \
    "read: $(command -v read || true)" \
    "date: $(command -v date || true)" \
    "sed: $(command -v sed || true)" \
    "printf: $(command -v printf || true)" \
    "tr: $(command -v tr || true)" \
    "rm: $(command -v rm || true)" \
    "mkdir: $(command -v mkdir || true)" \
    "mktemp: $(command -v mktemp || true)" \
    "curl: $(command -v curl || true) $(dc::internal::version::get curl || true)" \
    "jq: $(command -v jq || true) $(dc::internal::version::get jq || true)" \
    "openssl: $(command -v openssl || true) $(dc::internal::version::get openssl version || true)" \
    "shasum: $(command -v shasum || true) $(dc::internal::version::get shasum || true)" \
    "sqlite3: $(command -v sqlite3 || true) $(dc::internal::version::get sqlite3 || true)" \
    "uchardet: $(command -v uchardet || true) $(dc::internal::version::get uchardet || true)" \
    "iconv: $(command -v iconv || true) $(dc::internal::version::get iconv || true)" \
    "make: $(command -v make || true) $(dc::internal::version::get make || true)" \
    "git: $(command -v git || true) $(dc::internal::version::get git || true)" \
    "gcc: $(command -v gcc || true) $(dc::internal::version::get gcc || true)" \
    "PATH: $PATH" \
    "ENV: $(env)"
}

# Attach the error handler
dc::trap::register dc::error::handler
