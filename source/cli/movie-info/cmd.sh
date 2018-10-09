#!/usr/bin/env bash

readonly CLI_VERSION="1.0.0-rc"
readonly CLI_LICENSE="MIT License"
readonly CLI_DESC="spits out information about media files in a json format (duration, container, size, and for each track, codec, resolution or language)"
readonly CLI_USAGE="[-s] filename"

# Boot
dc::commander::init
dc::require::jq

if [ ! "$(command -v ffprobe)" ]; then
  dc::logger::error "You need ffprobe for this to work (part of ffmpeg)."
  exit "$ERROR_MISSING_REQUIREMENTS"
fi

if [ ! "$(command -v ffprobe)" ]; then
  dc::logger::error "You need mp4info for this to work (part of bento)."
  exit "$ERROR_MISSING_REQUIREMENTS"
fi


# Argument 1 is mandatory and must be a readable file
dc::fs::isfile "$1"

filename="$1"
dc::logger::info "[movie-info] $filename"
info::ffprobe "$filename"
