#!/usr/bin/env bash

# Set up the traps
trap 'dc::trap::signal::HUP     "$LINENO" "$?" "$BASH_COMMAND"' 1
trap 'dc::trap::signal::INT     "$LINENO" "$?" "$BASH_COMMAND"' 2
trap 'dc::trap::signal::QUIT    "$LINENO" "$?" "$BASH_COMMAND"' 3
trap 'dc::trap::signal::ABRT    "$LINENO" "$?" "$BASH_COMMAND"' 6
trap 'dc::trap::signal::ALRM    "$LINENO" "$?" "$BASH_COMMAND"' 14
trap 'dc::trap::signal::TERM    "$LINENO" "$?" "$BASH_COMMAND"' 15
trap 'dc::trap::exit            "$LINENO" "$?" "$BASH_COMMAND"' EXIT
trap 'dc::trap::err             "$LINENO" "$?" "$BASH_COMMAND"' ERR

dc::error::handler(){
  local exit="$1"
  local detail="$2"
  case "$exit" in
    # https://www.tldp.org/LDP/abs/html/exitcodes.html
    1)
      dc::logger::error "Generic bash error that should have been caught"
      dc::logger::error "Generic script failure"
    ;;
    2)
      dc::logger::error "Generic bash error that should have been caught"
      dc::logger::error "Misused shell builtin is a likely explanation"
      dc::logger::error "Last good command was: $3"
    ;;
    126)
      dc::logger::error "Generic bash error that should have been caught"
      dc::logger::error "Permission issue, or cannot execute command"
    ;;
    127)
      dc::logger::error "Generic bash error that should have been caught"
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

    # This is a lazy catch-all for non specific problems.
    "$ERROR_FAILED")
      dc::logger::error "Script failed: $detail"
    ;;
    # Denotes that something is not implemented or unsupported on the given platform
    "$ERROR_UNSUPPORTED")
      dc::logger::error "The requested operation is not supported: $detail"
    ;;
    # Some requirements are missing
    "$ERROR_MISSING_REQUIREMENTS")
      dc::logger::error "Sorry, you need $detail for this to work."
    ;;
    # Typical filesystem errors: file does not exist, is unreadable, or permission denied
    "$ERROR_FILESYSTEM")
      dc::logger::error "Filesystem error: $detail"
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
      dc::logger::error "UNCAUGHT EXCEPTION $exit $(dc::error::lookup "$exit"): $detail"
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
    "uname: $(uname -a)" \
    "bash: $(command -v bash) $(dc::require::version bash --version)" \
    "curl: $(command -v curl) $(dc::require::version curl --version)" \
    "grep: $(command -v grep) $(dc::require::version grep --version)" \
    "jq: $(command -v jq) $(dc::require::version jq --version)" \
    "openssl: $(command -v openssl) $(dc::require::version openssl version)" \
    "shasum: $(command -v shasum) $(dc::require::version shasum --version)" \
    "sqlite3: $(command -v sqlite3) $(dc::require::version sqlite3 --version)" \
    "uchardet: $(command -v uchardet) $(dc::require::version uchardet --version)" \
    "make: $(command -v bash) $(dc::require::version make --version)" \
    "gcc: $(command -v gcc) $(dc::require::version gcc --version)" \
    "ps: $(command -v ps)" \
    "read: $(command -v ps)" \
    "tput: $(command -v ps)" \
    "PATH: $PATH" \
    "ENV: $(env)"
}

dc::trap::register dc::error::handler
