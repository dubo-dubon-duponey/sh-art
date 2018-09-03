#!/usr/bin/env bash
readonly CLI_VERSION="0.0.1"
readonly CLI_LICENSE="MIT License"
readonly CLI_DESC="because I never remember makehybrid"
readonly CLI_USAGE="[-s] [--volume-name=name] [--iso-name=name] source-directory"

dc::commander::init

# Argument 1 is mandatory and must be a readable directory
directory="$1"
dc::fs::isdir "$directory"

iname="${DC_ARGV_ISO_NAME:-$(basename "$directory")}"
vname="${DC_ARGV_VOLUME_NAME:-$iname}"

dc::logger::info "Creating ISO $iname.iso with volume name $vname from $directory"
dc::logger::debug "hdiutil makehybrid -udf -udf-volume-name \"$vname\" -o \"$iname.iso\" \"$directory\""

if hdiutil makehybrid -udf -udf-volume-name "$vname" -o "$iname.iso" "$directory"; then
  dc::logger::error "Failed to create ISO!"
  exit "$ERROR_FAILED"
fi

dc::logger::info "Done"
