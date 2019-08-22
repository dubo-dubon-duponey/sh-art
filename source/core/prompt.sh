#!/usr/bin/env bash
##########################################################################
# Prompting
# ------
# https://unix.stackexchange.com/questions/222974/ask-for-a-password-in-posix-compliant-shell/222977
##########################################################################

dc::prompt::question() {
  local message="$1"
  local varname="$2"
  if [ ! -t 2 ] || [ ! -t 0 ]; then
    return
  fi

  read -r -p "$message" "$varname"
}

dc::prompt::confirm(){
  # XXX Use bel and flash
  if [ ! -t 2 ] || [ ! -t 0 ]; then
    return
  fi

  read -r
}

dc::prompt::credentials() {
  # TODO implement osxkeychain integration
  # No terminal stdin or stdout, can't ask for credentials
  if [ ! -t 2 ] || [ ! -t 0 ]; then
    return
  fi

  # No username? Then ask for one.
  read -r -p "$1" "$2"
  # No answer? Stay anonymous
  if [ ! "${!2}" ]; then
    return
  fi

  # Otherwise, ask for password
  read -r -s -p "$3" "$4"
  # Just to avoid garbling the output
  >&2 printf "\\n"
}

dc::prompt::password() {
  local message="$1"
  local varname="$2"
  # No terminal stdin or stdout, can't ask for credentials
  if [ ! -t 2 ] || [ ! -t 0 ]; then
    return
  fi

  # Ask for password
  read -r -s -p "$message" "$varname"
  # Just to avoid garbling the output
  >&2 printf "\\n"
}

# Keychain notes:
# Integation is not worth it and would be clunky
