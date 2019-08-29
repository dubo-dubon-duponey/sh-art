#!/usr/bin/env bash
##########################################################################
# Requirements
# ------
# Platforms, binaries, versions
##########################################################################

dc::require::platform(){
  [[ "$*" == *"$(uname)"* ]] || return "$ERROR_REQUIREMENT_MISSING"
}

dc::require::platform::mac(){
  dc::error::detail::set "macOS"
  dc::require::platform "$DC_PLATFORM_MAC"
}

dc::require::platform::linux(){
  dc::error::detail::set "linux"
  dc::require::platform "$DC_PLATFORM_LINUX"
}

dc::require::version(){
  local binary="$1"
  local versionFlag="$2"
  local varname

  dc::argument::check binary "^.+$" || return
  dc::argument::check versionFlag "^.+$" || return

  varname=DC_DEPENDENCIES_V_$(printf "%s" "$binary" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
  if [ ! ${!varname+x} ]; then
    while read -r line; do
      if printf "%s" "$line" | grep -qE "^[^0-9.]*([0-9]+[.][0-9]+).*"; then
        # Duh shit is harder with bash3
        read -r "${varname?}" <<<"$(sed -E 's/^[^0-9.]*([0-9]+[.][0-9]+).*/\1/' <<<"$line")"
        # XXX bash 4+ only?
        # declare -g "${varname?}"="$(printf "%s" "$line" | sed -E 's/^[^0-9.]*([0-9]+[.][0-9]+).*/\1/')"
        break
      fi
    # XXX interestingly, some application will output the result on stderr/stdout (jq version 1.3 is such an example)
    # We do not try to workaround here
    done <<< "$($binary "$versionFlag" 2>/dev/null)"
  fi
  printf "%s" "${!varname}"
}

dc::require(){
  local binary="$1"
  local versionFlag="$2"
  local version="$3"
  local provider="$4"
  [ "$provider" ] && provider="$(printf " (provided by: %s)" "$provider")"
  local varname
  local cVersion

  dc::argument::check binary "^.+$" || return

  varname=_DC_DEPENDENCIES_B_$(printf "%s" "$binary" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
  if [ ! ${!varname+x} ]; then
    command -v "$binary" >/dev/null \
      || {
        dc::error::detail::set "$binary${provider}"
        return "$ERROR_REQUIREMENT_MISSING"
      }
    read -r "${varname?}" <<<"true"
    # XXX
    # declare -g "${varname?}"=true
  fi

  [ "$versionFlag" ] || return 0
  dc::argument::check version "$DC_TYPE_FLOAT" || return

  cVersion="$(dc::require::version "$binary" "$versionFlag")"
  [ "${cVersion%.*}" -gt "${version%.*}" ] \
    || { [ "${cVersion%.*}" == "${version%.*}" ] && [ "${cVersion#*.}" -ge "${version#*.}" ]; } \
    || {
      dc::error::detail::set "$binary$provider version $version (now: ${!varname})"
      return "$ERROR_REQUIREMENT_MISSING"
    }
}
