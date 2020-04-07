#!/usr/bin/env bash
##########################################################################
# Internal API
# ------
# Meant to be used (widely) by the core library, but not outside.
# API is stable.
# None of these methods depend on anything in the lib.
# Also, none of them are trying to protect against invalid arguments / etc.
# Use only in a very controlled, safe way.
##########################################################################

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

# Use this for some important binaries (tr, date), that require surviving PATH="" (specially useful for testing)
dc::internal::wrap(){
  local bin="$1"
  shift
  local com

  # XXX this does not guarantee it can be executed of course
  com="$(command -v "$bin")" || {
    if [ -f "/bin/$bin" ]; then
      com="/bin/$bin"
    elif [ -f "/usr/bin/$bin" ]; then
      com="/usr/bin/$bin"
    else
      return 144
    fi
  }

#  >&2 echo ">>> Wrapping-> $com $@"
  "$com" "$@"
}

# Gets the version of a certain binary
# If sed is usable, will get a float out of this - otherwise, the entire version line
dc::internal::version::get(){
  local binary="$1"
  local versionFlag="${2:---version}"
  while read -r line; do
    if printf "%s" "$line" | dc::internal::wrap grep -q "^[^0-9.]*[0-9][0-9]*[.][0-9][0-9]*.*$"; then
      # This can survive not having sed around - will fallback to complete line, which of course won't be a float in some cases...
      dc::internal::wrap sed -E 's/^[^0-9.]*([0-9]+[.][0-9]+).*/\1/' <<<"$line" || printf "%s" "$line"
      break
    fi
  # XXX interestingly, some application will output the result on stderr/stdout (jq version 1.3 is such an example)
  # We do not try to workaround here and drop stderr altogether
  done <<< "$("$binary" "$versionFlag" 2>/dev/null)"
}

# "Normalize" a string to be usable in a variable name
# XXX this is kind of fucked-up - might still output stuff that is not var safe
dc::internal::varnorm(){
  dc::internal::wrap tr '[:lower:]' '[:upper:]' <<<"$1" | dc::internal::wrap tr "-" "_" || {
    if ! dc::internal::wrap grep -q "^[a-zA-Z_][a-zA-Z_]*[a-zA-Z0-9_]*$" <<<"$1"; then
      return 144
    fi
    printf "%s" "$1"
  }
}
