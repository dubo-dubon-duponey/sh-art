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
    1)
      dc::logger::error "Generic script error (https://www.tldp.org/LDP/abs/html/exitcodes.html)"
    ;;
    2)
      dc::logger::error "Script is broken - misused shell builtin is a likely explanation (https://www.tldp.org/LDP/abs/html/exitcodes.html)"
      dc::logger::error "Last good command was: $3"
    ;;
    126)
      dc::logger::error "Cannot execute (https://www.tldp.org/LDP/abs/html/exitcodes.html)"
    ;;
    127)
      dc::logger::error "Missing binary or a typo in a command name (https://www.tldp.org/LDP/abs/html/exitcodes.html)"
    ;;
    # XXX none of these two will be triggered with bash apparently
    128)
      dc::logger::error "XXXUNTESTEDXXX Invalid argument to exit"
    ;;
    255)
      dc::logger::error "XXXUNTESTEDXXX Additionally, the exit code we got ($exit) is out of range (0-255). We will exit 1."
    ;;

    *)
      dc::logger::error "UNCAUGHT EXCEPTION: $detail"
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
    "gcc: $(command -v gcc) $(dc::require::version gcc --version)" \
    "PATH: $PATH" \
    "ENV: $(env)"
}

dc::trap::register dc::error::handler
