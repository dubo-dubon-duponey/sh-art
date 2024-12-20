#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

# shellcheck disable=SC2034
readonly CLI_DESC="creates or mount/unmount iso files from a folder (because I never remember makehybrid syntax)"

# Initialize
dc::commander::initialize
dc::commander::declare::flag file ".+" "the iso filename (on create, default to the source directory name otherwise)" optional
dc::commander::declare::flag name ".+" "the descriptive name of the iso (fallback to filename othername" optional
dc::commander::declare::flag source ".+" "on create, the directory path from which to create the iso" optional
dc::commander::declare::arg 1 "^(create|mount|unmount)$" "action" "action to perform"
# Start commander
dc::commander::boot

# Requirements
dc::require::platform::mac

directory=${DC_ARG_SOURCE:-$(pwd)}
dc::fs::isdir "$directory"

# This: iname="${DC_ARG_FILE%.iso$*:-$(basename "$directory")}"
# BASHBUG Works with bash3, but not bash5...
# shellcheck disable=SC2295
[ -z "${DC_ARG_FILE+x}" ] || iname="${DC_ARG_FILE%.iso$*}"
iname="${iname:-$(basename "$directory")}"
vname="${DC_ARG_NAME:-$iname}"

case "$DC_ARG_1" in
  create)
    dc::logger::info "Creating ISO $iname.iso with volume name $vname from $directory"
    dc::logger::debug "hdiutil makehybrid -udf -udf-volume-name \"$vname\" -o \"$iname.iso\" \"$directory\""

    if ! hdiutil makehybrid -udf -udf-volume-name "$vname" -o "$iname.iso" "$directory"; then
      dc::logger::error "Failed to create ISO!"
      exit "$ERROR_GENERIC_FAILURE"
    fi
  ;;
  unmount)
    dc::logger::info "Mounting ISO $iname.iso"
    dc::logger::debug "hdiutil unmount \"/Volumes/$vname\""

    if ! hdiutil unmount "/Volumes/$vname"; then
      dc::logger::error "Failed to unmount ISO!"
      exit "$ERROR_GENERIC_FAILURE"
    fi
  ;;
  mount)
    dc::logger::info "Mounting ISO $iname.iso"
    dc::logger::debug "hdiutil mount \"$iname.iso\""

    if ! hdiutil mount "$iname.iso"; then
      dc::logger::error "Failed to mount ISO!"
      exit "$ERROR_GENERIC_FAILURE"
    fi
  ;;
esac
