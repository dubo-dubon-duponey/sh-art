#!/usr/bin/env bash

_have_bash(){
  local bashVersion
  if ! bashVersion="$(bash --version 2>/dev/null)"; then
    >&2 printf "[%s] %s\\n" "$(date)" "[ERROR] Dude! Amazon doesn't ship Bash on your planet?"
    exit 206
  fi
  bashVersion=${bashVersion#*version }
  bashVersion=${bashVersion%%-*}
  if [ "${bashVersion%%.*}" -lt "3" ]; then
    >&2 printf "[%s] %s\\n" "$(date)" "[ERROR] Bash is too old. Upgrade to version 3 at least to use this."
    exit 206
  fi

  readonly DC_DEPENDENCIES_V_BASH="$bashVersion"
}

_have_bash

_gnu_grep(){
  if grep --version | grep -q gnu; then
    readonly _GNUGREP="true"
  fi
}

_gnu_grep
