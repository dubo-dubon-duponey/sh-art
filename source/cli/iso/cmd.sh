#!/usr/bin/env bash

readonly CLI_VERSION="0.1.0"
readonly CLI_LICENSE="MIT License"
readonly CLI_DESC="because I never remember makehybrid"

# Initialize
dc::commander::initialize
dc::commander::declare::flag file ".+" "optional" "the iso filename (on create, default to the source directory name otherwise)"
dc::commander::declare::flag name ".+" "optional" "the descriptive name of the iso (fallback to filename othername"
dc::commander::declare::flag source ".+" "optional" "on create, the directory path from which to create the iso"
dc::commander::declare::arg 1 "^(create|mount|unmount)$" "" "action" "action to perform"
# Start commander
dc::commander::boot

# Requirements
dc::require::platform::mac

directory=${DC_ARGV_SOURCE:-$(pwd)}
dc::fs::isdir "$directory"

iname="${DC_ARGV_FILE%.iso$*:-$(basename "$directory")}"
vname="${DC_ARGV_NAME:-$iname}"

case "$1" in
  create)
    dc::logger::info "Creating ISO $iname.iso with volume name $vname from $directory"
    dc::logger::debug "hdiutil makehybrid -udf -udf-volume-name \"$vname\" -o \"$iname.iso\" \"$directory\""

    if ! hdiutil makehybrid -udf -udf-volume-name "$vname" -o "$iname.iso" "$directory"; then
      dc::logger::error "Failed to create ISO!"
      exit "$ERROR_FAILED"
    fi
  ;;
  unmount)
    dc::logger::info "Mounting ISO $iname.iso"
    dc::logger::debug "hdiutil unmount \"/Volumes/$vname\""

    if ! hdiutil unmount "/Volumes/$vname"; then
      dc::logger::error "Failed to unmount ISO!"
      exit "$ERROR_FAILED"
    fi
  ;;
  mount)
    dc::logger::info "Mounting ISO $iname.iso"
    dc::logger::debug "hdiutil mount \"$iname.iso\""

    if ! hdiutil mount "$iname.iso"; then
      dc::logger::error "Failed to mount ISO!"
      exit "$ERROR_FAILED"
    fi
  ;;
esac
