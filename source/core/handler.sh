#!/usr/bin/env bash

dc::error::handler(){
  local exit="$1"
  local detail="$2"
  local command="$3"
  local lineno="$4"

  dc::logger::error "[CONSOLE EXIT HANDLER] Exit code:       $exit"
  dc::logger::error "[CONSOLE EXIT HANDLER]      condition:  $(dc::error::lookup "$exit")"
  dc::logger::error "[CONSOLE EXIT HANDLER]      detail:     $detail"
  dc::logger::error "[CONSOLE EXIT HANDLER]      command:    $command"
  dc::logger::error "[CONSOLE EXIT HANDLER]      line:       $lineno"

  if ! dc::logger::ismute; then
    cat -n "$0" |  >&2 dc::wrapped::grep "^\s+$((lineno - 2))\s" || true
#    >&2 printf "\n"
    cat -n "$0" |  >&2 dc::wrapped::grep "^\s+$((lineno - 1))\s" || true
#    >&2 printf "\n"
    # Coloring
    [ ! "$TERM" ] || [ ! -t 2 ] || >&2 dc::internal::securewrap tput setaf "$DC_COLOR_RED" 2>/dev/null || true
    cat -n "$0" |  >&2 dc::wrapped::grep "^\s+$((lineno))\s" || true
#    >&2 printf "\n"
    [ ! "$TERM" ] || [ ! -t 2 ] || >&2 dc::internal::securewrap tput op 2>/dev/null || true
    cat -n "$0" |  >&2 dc::wrapped::grep "^\s+$((lineno + 1))\s" || true
#    >&2 printf "\n"
    cat -n "$0" |  >&2 dc::wrapped::grep "^\s+$((lineno + 2))\s" || true
#    >&2 printf "\n"
  fi

  case "$exit" in
    # https://www.tldp.org/LDP/abs/html/exitcodes.html
    "$ERROR_SYSTEM_GENERIC_ERROR")
      dc::logger::error "[CONSOLE EXIT HANDLER] Explanation: generic bash failure"
    ;;
    "$ERROR_SYSTEM_SHELL_BUILTIN_MISUSE")
      dc::logger::error "[CONSOLE EXIT HANDLER] Explanation: you misused a shell builtin (like: wrong arguments)"
    ;;
    "$ERROR_SYSTEM_COMMAND_NOT_EXECUTABLE")
      dc::logger::error "[CONSOLE EXIT HANDLER] Explanation: permission issue with the binary you called, or otherwise cannot execute requested command"
    ;;
    "$ERROR_SYSTEM_COMMAND_NOT_FOUND")
      dc::logger::error "[CONSOLE EXIT HANDLER] Explanation: you called a binary that cannot be found, or typoed a command name"
    ;;
    # XXX apparently, with bash 3, actually out of range exit code ends-up code % 255
    # While actually invalid exit code end-up 255
    "$ERROR_SYSTEM_INVALID_EXIT_ARGUMENT")
      dc::logger::error "XXXSHOULDNEVERHAPPENXXX"
      dc::logger::error "XXXSHOULDNEVERHAPPENXXX Invalid argument to exit"
    ;;
    "$ERROR_SYSTEM_EXIT_OUT_OF_RANGE")
      dc::logger::error "[CONSOLE EXIT HANDLER] Explanation: a call to exit used an invalid exit code"
    ;;

    # Signals
    "$ERROR_SYSTEM_SIGHUP")
      dc::logger::error "[CONSOLE EXIT HANDLER] Explanation: got signal SIGHUP"
    ;;
    "$ERROR_SYSTEM_SIGINT")
      dc::logger::error "[CONSOLE EXIT HANDLER] Explanation: got signal SIGINT"
    ;;
    "$ERROR_SYSTEM_SIGQUIT")
      dc::logger::error "[CONSOLE EXIT HANDLER] Explanation: got signal SIGQUIT"
    ;;
    "$ERROR_SYSTEM_SIGABRT")
      dc::logger::error "[CONSOLE EXIT HANDLER] Explanation: got signal SIGABRT"
    ;;
    "$ERROR_SYSTEM_SIGKILL")
      dc::logger::error "[CONSOLE EXIT HANDLER] Explanation: got signal SIGKILL"
    ;;
    "$ERROR_SYSTEM_SIGALRM")
      dc::logger::error "[CONSOLE EXIT HANDLER] Explanation: got signal SIGALRM"
    ;;
    "$ERROR_SYSTEM_SIGTERM")
      dc::logger::error "[CONSOLE EXIT HANDLER] Explanation: got signal SIGTERM"
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
      dc::logger::error "[CONSOLE EXIT HANDLER] Explanation: verify that the provided path ($detail) exist and/or is writable"
    ;;
    # Some requirements are missing
    "$ERROR_REQUIREMENT_MISSING")
      dc::logger::error "[CONSOLE EXIT HANDLER] Explanation: you need to install $detail for this to work."
    ;;

    # This is a lazy catch-all for non specific problems.
    "$ERROR_GENERIC_FAILURE")
      dc::logger::error "[CONSOLE EXIT HANDLER] Explanation: non specific script failure. You should report this"
    ;;
    # Denotes that something is not implemented or unsupported on the given platform
    "$ERROR_UNSUPPORTED")
      dc::logger::error "[CONSOLE EXIT HANDLER] Explanation: the requested operation is not supported/implemented"
    ;;
    # Provided argument doesn't validate
    "$ERROR_ARGUMENT_INVALID")
      dc::logger::error "[CONSOLE EXIT HANDLER] Explanation: provided argument $detail is invalid"
    ;;
    # We waited for the user for too long
    "$ERROR_ARGUMENT_TIMEOUT")
      dc::logger::error "[CONSOLE EXIT HANDLER] Explanation: timed-out waiting for user input after $detail seconds"
    ;;
    # Something is amiss
    "$ERROR_ARGUMENT_MISSING")
      dc::logger::error "[CONSOLE EXIT HANDLER] Explanation: required argument $detail is missing"
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
    "bash: $(command -v bash || true) $(dc::internal::version::get bash)" \
    "grep: $(command -v grep || true) $(dc::internal::version::get grep)" \
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
    "curl: $(command -v curl || true) $(dc::internal::version::get curl)" \
    "jq: $(command -v jq || true) $(dc::internal::version::get jq)" \
    "openssl: $(command -v openssl || true) $(dc::internal::version::get openssl version)" \
    "shasum: $(command -v shasum || true) $(dc::internal::version::get shasum)" \
    "sqlite3: $(command -v sqlite3 || true) $(dc::internal::version::get sqlite3)" \
    "uchardet: $(command -v uchardet || true) $(dc::internal::version::get uchardet)" \
    "iconv: $(command -v iconv || true) $(dc::internal::version::get iconv)" \
    "make: $(command -v make || true) $(dc::internal::version::get make)" \
    "git: $(command -v git || true) $(dc::internal::version::get git)" \
    "gcc: $(command -v gcc || true) $(dc::internal::version::get gcc)" \
    "PATH: $PATH" \
    "ENV: $(env)"
}
