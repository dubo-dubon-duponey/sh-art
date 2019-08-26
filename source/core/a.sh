#!/usr/bin/env bash

if [ "$(sh -c 'ps -p $$ -o ppid=' | xargs ps -o comm= -p)" != "bash" ]; then
  >&2 printf "[%s] %s\\n" "$(date)" "You need bash for this to work"
  exit 1
fi

# The reason we check that now is that grep is central to many validation mechanism
# If we would check grep presence, that would introduce circular deps (require vs. internal)
if ! command -v "grep" >/dev/null; then
  >&2 printf "[%s] %s\\n" "$(date)" "You need grep for this to work"
  exit 1
fi
