#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

##########################################################################
# Requirements
# ------
# Platforms, binaries, versions
##########################################################################

dc::require::platform(){
  local required="${1:-}"

  dc::argument::check required "$DC_TYPE_STRING" || return

  [[ "$required" == *"$(dc::internal::securewrap uname)"* ]] || {
    dc::error::throw REQUIREMENT_MISSING "$required [$(dc::internal::securewrap uname)]" || return
  }
}

dc::require::platform::mac(){
  dc::require::platform "$DC_PLATFORM_MAC" || return
}

dc::require::platform::linux(){
  dc::require::platform "$DC_PLATFORM_LINUX" || return
}

# @argument string binary
# @argument float version
# @argument [string versionFlag]
# @argument [string provider]
# @returns REQUIREMENT_MISSING
# @returns ARGUMENT_INVALID
# XXX this is likely breaking shit on bash5 - just wrap everything (eg: command -v at least)
dc::require(){
  local binary="${1:-}"
  local version="${2:-}"
  local versionFlag="${3:-}"
  local provider="${4:-}"
  [ ! "$provider" ] || provider=" (provided by: $provider)"

  local varname

  # XXX this is a victim of the named pipe bash fuckerism - bash5 will mangle fd with argument checking
  dc::argument::check binary "$DC_TYPE_STRING" || return

  varname="$(dc::internal::varnorm "_DC_DEPENDENCIES_B_$binary")"
  if [ ! ${!varname+x} ]; then
    command -v "$binary" >/dev/null \
      || dc::error::throw REQUIREMENT_MISSING "$binary${provider}" \
      || return
    read -r "${varname?}" <<<"true"
    # XXX this makes it hard to test/mock, disabling
    # readonly "${varname?}"
    # Meaning sub shells will benefit from that as well
    export "${varname?}"
    # XXX
    # declare -g "${varname?}"=true
  fi

  [ "$version" ] || return 0

  dc::argument::check version "$DC_TYPE_FLOAT" || return
  [ ! "$versionFlag" ] || dc::argument::check versionFlag "$DC_TYPE_STRING" || return

  local cVersion

  varname="$(dc::internal::varnorm "DC_DEPENDENCIES_V_$binary")"
  if [ ! ${!varname+x} ]; then
    read -r cVersion <<<"$(dc::internal::version::get "$binary" "$versionFlag")"
    # The returned version could be empty, which means the passed version flag is invalid
    [ "${cVersion%.*}" ] \
      || dc::error::throw ARGUMENT_INVALID "$binary${provider}: $cVersion" \
      || return

    # Otherwise, cache it, lock it, export it
    read -r "${varname?}" <<<"$cVersion"
    readonly "${varname?}"
    export "${varname?}"
  fi

  cVersion="${!varname}"
  # If not empty, we have a guarantee that it's an int (see implem)
  [ "${cVersion%.*}" -gt "${version%.*}" ] \
    || { [ "${cVersion%.*}" == "${version%.*}" ] && [ "${cVersion#*.}" -ge "${version#*.}" ]; } \
    || dc::error::throw REQUIREMENT_MISSING "$binary$provider version $version (now: ${!varname})" \
    || return
}
