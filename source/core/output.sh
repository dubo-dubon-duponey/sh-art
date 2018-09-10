#!/usr/bin/env bash
##########################################################################
# Fancy stdout
# ------
##########################################################################

# Output $1 json:
# - as-is if "raw" ($2) is set
# - through jq (adapts to being piped)
dc::output::json() {
  raw="$2"
  if [ -t 1 ]; then
    # Pretty it if we are not piped
    printf "%s" "$1" | jq
  else
    # If piped, and we want it raw (for checksum validation, passthrough)
    if [ "$raw" ]; then
      printf "%s" "$1"
    else
    # Otherwise, still format through jq
      printf "%s" "$1" | jq "."
    fi
  fi
}
