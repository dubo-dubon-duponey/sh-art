#!/usr/bin/env bash

readonly CLI_VERSION="0.0.1"
readonly CLI_LICENSE="MIT License"
readonly CLI_DESC="because I never remember how to use ffmpeg"
readonly CLI_USAGE="[-s] [--destination=folder] [--delete] [--convert=X] [--remove=X Y Z] [--extract=X:ln.ext Y:ln.ext Z:ln.ext] filename"

# Boot
dc::commander::init

# Argument 1 is mandatory and must be a readable file
dc::fs::isfile "$1"

filename=$(basename "$1")
# extension="${filename##*.}"
filename="${filename%.*}"

# Optional destination must be a writable directory, and create it is it does not exist
if [ "$DC_ARGV_DESTINATION" ]; then
  dc::fs::isdir "$DC_ARGV_DESTINATION" writable create
  destination=$DC_ARGV_DESTINATION/$filename
else
  destination=$(dirname "$1")/$filename-convert
fi

# Validate optional arguments syntax
if [ "$DC_ARGV_CONVERT" ]; then
  dc::argv::flag::validate convert "^[0-9]$"
fi
if [ "$DC_ARGV_REMOVE" ]; then
  dc::argv::flag::validate remove "^[0-9]+(?: [0-9]+)*$"
fi
if [ "$DC_ARGV_EXTRACT" ]; then
  dc::argv::flag::validate extract "^[0-9]+:[^ ]+(?: [0-9]+:[^ ]+)*$"
fi



if ! transmogrify::do "$1" "$destination" "${DC_ARGV_CONVERT}" "${DC_ARGV_REMOVE}" "${DC_ARGV_EXTRACT}"; then
  dc::logger::error "Failed to convert $filename!"
  if [ -f "$destination.mp4" ]; then
    rm "$destination.mp4"
  fi
  exit "$ERROR_FAILED"
fi

dc::logger::info "Successfully transmogrified $1"
if [ "$DC_ARGE_DELETE" ] || [ "$DC_ARGE_D" ]; then
  dc::logger::info "Press enter to delete the original"
  dc::prompt::confirm
  rm "$1"
  dc::logger::info "Original deleted"
else
  dc::logger::info "Original preserved"
fi
