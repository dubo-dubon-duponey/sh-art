#!/usr/bin/env bash

# Enforce having bash version 3 or more recent
_dc_internal::have::bash(){
  local bashVersion
  if ! bashVersion="$(bash --version 2>/dev/null)"; then
    >&2 printf "[%s] %s\\n" "$(date)" "[ERROR] Dude! Amazon doesn't ship Bash on your planet?"
    # ERROR_MISSING_REQUIREMENTS
    exit 206
  fi
  bashVersion=${bashVersion#*version }
  bashVersion=${bashVersion%%-*}
  if [ "${bashVersion%%.*}" -lt "3" ]; then
    >&2 printf "[%s] %s\\n" "$(date)" "[ERROR] Bash is too old. Upgrade to version 3 at least to use this."
    # ERROR_MISSING_REQUIREMENTS
    exit 206
  fi

  # shellcheck disable=SC2034
  readonly DC_DEPENDENCIES_V_BASH="$bashVersion"
}

_dc_internal::have::bash

# Enforce having grep, and sets _DC_PRIVATE_GNUGREP if it's the GNU version
_dc_internal::have::grep(){
  local grepVersion
  if ! grepVersion="$(grep --version 2>/dev/null)"; then
    >&2 printf "[%s] %s\\n" "$(date)" "[ERROR] Dude! You need grep!"
    # ERROR_MISSING_REQUIREMENTS
    exit 206
  fi
  if printf "%s" "$grepVersion" | grep -q gnu; then
    # shellcheck disable=SC2034
    readonly _DC_PRIVATE_GNUGREP=true
  fi
}

_dc_internal::have::grep
