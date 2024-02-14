#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

##########################################################################
# Internal API
# ------
# Meant to be used (widely) by the core library, but not outside.
# API is stable.
# None of these methods depend on anything in the lib.
# Also, none of them are trying to protect against invalid arguments / etc.
# Use only in a very controlled, safe way.
##########################################################################

# This wrapping serves two purposes:
# * ensure some survivability in case PATH is foobar
# * safeguard against bash 3 macOS which discards file descriptors after an external binary call (is this still true with 3.2?)
# All binary calls MUST be called through this method instead (built-ins do NOT count: printf, echo, read)
dc::internal::securewrap(){
  local bin="$1"
  shift
  local exit=0
  local com

  com="$(command -v "$bin")" || {
    if [ -f "/bin/$bin" ]; then
      com="/bin/$bin"
    elif [ -f "/usr/bin/$bin" ]; then
      com="/usr/bin/$bin"
    else
      return 144
    fi
  }

  exec 3>&1
  exec 4>&2
  # XXX validate this is right
  # This will avoid triggering trap ERR at this line, which is just noise
  # Question though: are we missing up output here?
  #_="$($com "$@" 2>&4 1>&3)" || exit=$?
  exit="$($com "$@" 2>&4 1>&3 || printf "%s" "$?")"
  if [ "$exit" ]; then
    exec 3>&-
    exec 4>&-
    return "$exit"
  fi
  exec 3>&-
  exec 4>&-
}

# "Normalize" a string to be usable in a variable name
# XXX this is kind of fucked-up - might still output stuff that is not var safe
dc::internal::varnorm(){
  dc::internal::securewrap tr '[:lower:]' '[:upper:]' <<<"$1" 2>/dev/null | dc::internal::securewrap tr "-" "_" 2>/dev/null || {
    if ! dc::internal::securewrap grep -q "^[a-zA-Z_][a-zA-Z_]*[a-zA-Z0-9_]*$" <<<"$1"; then
      return 144
    fi
    printf "%s" "$1"
  }
}

_DC_PRIVATE_ERROR_CODEPOINT=143

# This is used by core to register "errors", starting with 144 ("missing requirement")
dc::internal::error::register(){
  # No check is applied to the error name in core - don't mess this up!
  local name="$1"
  local codepoint="${2:-}"

  if [ ! "$codepoint" ]; then
    # No check is applied to the codepoint range in core (144-254)
    _DC_PRIVATE_ERROR_CODEPOINT=$(( _DC_PRIVATE_ERROR_CODEPOINT + 1 ))
    codepoint="$_DC_PRIVATE_ERROR_CODEPOINT"
  fi

  # XXX bash3 does not fly with this
  # declare -g "${name?}"="$_DC_PRIVATE_ERROR_CODEPOINT"
  read -r "ERROR_${name?}" <<<"$codepoint"
  export "ERROR_${name?}"
  readonly "ERROR_${name?}"
}

# Gets the version of a certain binary
# If sed is usable, will get a float out of this - otherwise, the entire version line
# TODO
# - do better when the binary is not there
# - reevaluate dropping stderr
dc::internal::version::get(){
  local binary="$1"
  local versionFlag="${2:---version}"
  while read -r line; do
    if printf "%s" "$line" | dc::internal::securewrap grep -Eq "^[^0-9.]*[0-9][0-9]*([.][0-9][0-9]*)*.*$"; then
      # This can survive not having sed around - will fallback to complete line, which of course won't be a float in some cases...
      # XXX ^ does not sound like the best of ideas for portability of consumer script...
      dc::internal::securewrap sed -E 's/^[^0-9.]*([0-9]+([.][0-9]+)?).*/\1/' <<<"$line" || printf "%s" "$line"
      break
    fi
  # XXX interestingly, some application will output the result on stderr/stdout (jq version 1.3 is such an example)
  # We do not try to workaround here and drop stderr altogether
  done <<<"$(dc::internal::securewrap "$binary" "$versionFlag" 2>/dev/null)"
}
