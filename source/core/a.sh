#!/usr/bin/env bash

haveBash(){
  local psout

  # The best approach requires procps to be installed
  if command -v ps > /dev/null; then
    # bug busybox...
    if ! psout="$(ps -p $$ -c -o command= 2>/dev/null)"; then
      # shellcheck disable=SC2009
      psout="$(ps -o ppid,comm | grep $$)"
      psout="${psout##* }"
    fi
    if [ "$psout" != "bash" ]; then
      >&2 printf "[%s] %s\\n" "$(date)" "This only works with bash"
      return 1
    fi
    return 0
  fi

  # This is really a survival fallback, and probably not that robust
  >&2 printf "[%s] %s\\n" "$(date)" "Your system lacks ps"
  if [ ! "$BASH" ] || [ "$(command -v bash)" != "$BASH" ]; then
    >&2 printf "[%s] %s\\n" "$(date)" "This only works with bash. BASH: $BASH - command -v bash: $(command -v bash)"
    return 1
  fi
  return 0
}

# This thing is not getting any better
haveBash || exit 1

# if [ "$(sh -c 'ps -p $$ -o ppid=' | xargs ps -o comm= -p)" != "bash" ]; then

# The reason we check that now is that grep is central to many validation mechanism
# If we would check grep presence, that would introduce circular deps (require vs. internal)
# Since grep is a central part of everything in core...
if ! command -v "grep" >/dev/null; then
  >&2 printf "[%s] %s\\n" "$(date)" "You need grep for this to work"
  exit 1
fi
