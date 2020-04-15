#!/usr/bin/env bash
##########################################################################
# Entrypoint: bash
# ------
# This is meant to run before anything else, and should have zero dependency on the rest.
# The purpose of this is ONLY to ensure we are running with bash.
# The "date" binary is being called on, though it will fail gracefully if not here.
# This works better with ps, though we can survive without.
##########################################################################

# Ensure we are running with bash
# Trying very hard here to have this run on all shells (so, no fancy function name, etc)
_dc_private_hasBash(){
  local psout

  # The best approach requires procps to be installed
  if command -v ps > /dev/null; then
    # And this is good, but... busybox will fail on -p...
    if ! psout="$(ps -p $$ -c -o command= 2>/dev/null)"; then
      >&2 printf "[%s] WARNING: %s\n" "$(date 2>/dev/null || true)" "Your ps does not support -p (busybox?)"
      # This is dangerously not robust - extra care has to be taken to avoid collisions on the pid (escpecially in a docker build context where pid=1)
      # shellcheck disable=SC2009
      psout="$(ps -o ppid,comm | grep "^\s*$$ ")"
      psout="${psout##* }"
      psout="${psout##*-}"
      psout="${psout##*/}"
    fi
    # So, not bash? Fail and exit
    if [ "$psout" != "bash" ]; then
      >&2 printf "[%s] ERROR: %s\n" "$(date 2>/dev/null || true)" "This only works with bash."
      return 144
    fi
    return 0
  fi

  # From that point on is really a survival fallback - ps is not even installed on this system (or PATH is foobar)
  # None of this is robust

  # See something
  # >&2 printf "[%s] WARNING: %s\n" "$(date 2>/dev/null || true)" "Your system lacks ps"

  # Say something
  if ! command -v bash > /dev/null; then
    >&2 printf "[%s] WARNING: %s\n" "$(date 2>/dev/null || true)" "Cannot find bash in your path"
  fi

  # Relying on the value of $BASH sucks but at that point, it's all we have
  if [ "$BASH" != "/bin/bash" ]; then
    >&2 printf "[%s] %s\n" "$(date 2>/dev/null || true)" "This only works with bash (BASH: $BASH - command -v bash: $(command -v bash))"
    return 144
  fi

  return 0
}

_dc_private_hasBash || exit

set -eu -o pipefail
