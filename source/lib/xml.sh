#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

dc::wrapped::xmlstarlet(){
  dc::require xmlstarlet || return

  xmlstarlet "$@" 2>/dev/null \
    || { dc::error::detail::set "xmlstarlet" && return "$ERROR_BINARY_UNKNOWN_ERROR"; }
}

dc::xml::get(){
  local key="$1"
  local root="${2:-/}"
  local file="${3:-/dev/stdin}"

  dc::wrapped::xmlstarlet sel -T -t -m "$root" -v "@${key}" -n "$file"
}

dc::xml::set(){
  local key="$1"
  local value="$2"
  local root="${3:-/}"
  local file="${4:-/dev/stdin}"

  local count

  count="$(dc::wrapped::xmlstarlet sel -t -v "count($root/@${key})" "$file")"
  count=$((count + 0))
  if [ "$count" -gt 0 ]; then
    dc::wrapped::xmlstarlet ed --inplace --update "$root/@$key" -v "$value" "$file"
  else
    dc::wrapped::xmlstarlet ed --inplace --insert "$root"  --type attr -n "$key" -v "$value" "$file"
  fi
}
