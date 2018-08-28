#!/usr/bin/env bash
##########################################################################
# Prompting
# ------
##########################################################################

dc::prompt::question() {
  local message="$1"
  if [ ! -t 2 ] || [ ! -t 0 ]; then
    return
  fi

  read -p "$message" $2
}

dc::prompt::confirm(){
  if [ ! -t 2 ] || [ ! -t 0 ]; then
    return
  fi

  read
}

dc::prompt::credentials() {
  # TODO implement osxkeychain integration
  # No terminal stdin or stdout, can't ask for credentials
  if [ ! -t 2 ] || [ ! -t 0 ]; then
    return
  fi

  # No username? Then ask for one.
  read -p "$1" $2
  # No answer? Stay anonymous
  if [ ! "${!2}" ]; then
    return
  fi

  # Otherwise, ask for password
  read -s -p "$3" $4
  # Just to avoid garbling the output
  >&2 echo
}
