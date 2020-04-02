#!/usr/bin/env bash
##########################################################################
# Entrypoint
# ------
# This just enforces basic system check to make sure we can survive
# That's basically having bash and grep
##########################################################################

# This thing is not getting any better
haveBash(){
  local psout

  # The best approach requires procps to be installed
  if command -v ps > /dev/null; then
    # And this is good, but...
    if ! psout="$(ps -p $$ -c -o command= 2>/dev/null)"; then
      # busybox...
      # shellcheck disable=SC2009
      psout="$(ps -o ppid,comm | grep "^\s*$$ ")"
      psout="${psout##* }"
    fi
    if [ "$psout" != "bash" ]; then
      >&2 printf "[%s] %s\n" "$(date)" "This only works with bash"
      return 144
    fi
    return 0
  fi

  # This is really a survival fallback, and probably not that robust
  >&2 printf "[%s] %s\n" "$(date)" "Your system lacks ps"
  if [ ! "$BASH" ] || [ "$(command -v bash)" != "$BASH" ]; then
    >&2 printf "[%s] %s\n" "$(date)" "This only works with bash. BASH: $BASH - command -v bash: $(command -v bash)"
    return 144
  fi
  return 0
}

haveGrep(){
  # The reason we check that now is that grep is central to many validation mechanism
  # If we would check using the library itself, that would introduce circular deps (require vs. internal) and costly lookups
  if ! command -v "grep" >/dev/null; then
    >&2 printf "[%s] %s\n" "$(date)" "You need grep for this to work"
    return 144
  fi
}

haveBash || exit
haveGrep || exit
