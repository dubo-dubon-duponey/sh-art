#!/usr/bin/env bash

readonly CLI_VERSION="0.0.1"
readonly CLI_LICENSE="MIT License"
readonly CLI_DESC="because I never remember makehybrid"
readonly CLI_USAGE="[-s] [--file=name] [--name=name] [--source=source-directory] create|mount|unmount"

dc::commander::init
dc::require::platform::mac

dc::argv::arg::validate 1 "(create|mount|unmount)"

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
