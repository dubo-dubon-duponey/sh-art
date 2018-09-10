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
  if [ $(uname) != "$DC_PLATFORM_MAC" ]; then
    dc::logger::error "This is working only on mac, sorry."
    exit "$ERROR_MISSING_REQUIREMENTS"
  fi
}

dc::require::platform::linux(){
  if [ $(uname) != "$DC_PLATFORM_LINUX" ]; then
    dc::logger::error "This is working only on linux, sorry."
    exit "$ERROR_MISSING_REQUIREMENTS"
  fi
}

dc::require::brew(){
  # First and foremost, depend on brew (through tarmac)
  if [ ! "$(command -v brew)" ]; then
    dc::logger::error "You need homebrew for this to work. You can install it using the 'tarmac' helper with:"
    dc::logger::info "bash -c \$(curl -fsSL https://raw.github.com/dubo-dubon-duponey/tarmac/master/init)"
    exit "$ERROR_MISSING_REQUIREMENTS"
  fi
}

dc::require::jq(){
  local jqVersion
  if ! jqVersion="$(jq --version 2>/dev/null)"; then
    dc::logger::error "Please install jq for this shcript to work."
    exit "$ERROR_MISSING_REQUIREMENTS"
  fi
  readonly DC_VERSION_JQ="$jqVersion"
}
