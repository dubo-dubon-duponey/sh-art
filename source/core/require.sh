#!/usr/bin/env bash

readonly DC_PLATFORM_MAC=Darwin
readonly DC_PLATFORM_LINUX=Linux

dc::require::platform(){
  if [[ "$*" != *"$(uname)"* ]]; then
    dc::logger::error "Sorry, your platform $(uname) is not supported by this."
    exit "$ERROR_MISSING_REQUIREMENTS"
  fi
}

dc::require::platform::mac(){
  if [ "$(uname)" != "$DC_PLATFORM_MAC" ]; then
    dc::logger::error "This is working only on mac, sorry."
    exit "$ERROR_MISSING_REQUIREMENTS"
  fi
}

dc::require::platform::linux(){
  if [ "$(uname)" != "$DC_PLATFORM_LINUX" ]; then
    dc::logger::error "This is working only on linux, sorry."
    exit "$ERROR_MISSING_REQUIREMENTS"
  fi
}

dc::require::brew(){
  if ! command -v brew >/dev/null; then
    dc::logger::error "You need homebrew for this to work. You can install it using the 'tarmac' helper with:"
    dc::logger::info "bash -c \$(curl -fsSL https://raw.github.com/dubo-dubon-duponey/tarmac/master/init)"
    exit "$ERROR_MISSING_REQUIREMENTS"
  fi
}

dc::require::git(){
  if ! command -v git >/dev/null; then
    dc::logger::error "You need git for this to work."
    exit "$ERROR_MISSING_REQUIREMENTS"
  fi
}

dc::require::jq(){
  local jqVersion
  if ! jqVersion="$(jq --version 2>/dev/null)"; then
    dc::logger::error "Please install jq for this shcript to work."
    exit "$ERROR_MISSING_REQUIREMENTS"
  fi
  readonly DC_VERSION_JQ="${jqVersion##*-}"
}

dc::require(){
  local binary="$1"
  local versionFlag="$2"
  local version="$3"
  local varname
  varname=_DC_DEPENDENCIES_B_$(printf "%s" "$binary" | tr '[:lower:]' '[:upper:]')
  if [ ! ${!varname+x} ]; then
    if ! command -v "$binary" >/dev/null; then
      dc::logger::error "You need $binary for this to work."
      exit "$ERROR_MISSING_REQUIREMENTS"
    fi
    read -r "${varname?}" < <(printf "true")
  fi
  if [ ! "$versionFlag" ]; then
    return
  fi
  varname=DC_DEPENDENCIES_V_$(printf "%s" "$binary" | tr '[:lower:]' '[:upper:]')
  if [ ! ${!varname+x} ]; then
    read -r "${varname?}" < <($binary "$versionFlag" 2>/dev/null | sed -E 's/^[^0-9.]+([0-9]+[.][0-9]+).*/\1/')
  fi
  if [[ "$version" > "${!varname}" ]]; then
    dc::logger::error "You need $binary (version >= $version) for this to work (you currently have ${!varname})."
    exit "$ERROR_MISSING_REQUIREMENTS"
  fi
}

dc::optional(){
  local binary="$1"
  local versionFlag="$2"
  local version="$3"
  local varname
  varname=_DC_DEPENDENCIES_B_$(printf "%s" "$binary" | tr '[:lower:]' '[:upper:]')
  if [ ! ${!varname+x} ]; then
    if ! command -v "$binary" >/dev/null; then
      dc::logger::warning "Optional binary $binary is recommended for this."
      return
    fi
    read -r "${varname?}" < <(printf "true")
  fi
  if [ ! "$versionFlag" ]; then
    return
  fi
  varname=DC_DEPENDENCIES_V_$(printf "%s" "$binary" | tr '[:lower:]' '[:upper:]')
  if [ ! ${!varname+x} ]; then
    read -r "${varname?}" < <($binary "$versionFlag" 2>/dev/null | sed -E 's/^[^0-9.]+([0-9]+[.][0-9]+).*/\1/')
  fi
  if [[ "$version" > "${!varname}" ]]; then
    dc::logger::warning "Optional $binary (version >= $version) is recommended, but you have it as ${!varname})."
  fi
}
