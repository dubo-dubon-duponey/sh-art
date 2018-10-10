#!/usr/bin/env bash

readonly CLI_VERSION="1.0.0-rc"
readonly CLI_LICENSE="MIT License"
readonly CLI_DESC="spits out information about media files in a json format (duration, container, size, and for each track, codec, resolution or language)"
readonly CLI_USAGE="[-s] filename"

# Boot
dc::commander::init
dc::require::jq

if [ ! "$(command -v ffprobe)" ]; then
  dc::logger::error "You need ffprobe or avprobe for this to work (part of ffmpeg)."
  exit "$ERROR_MISSING_REQUIREMENTS"
fi

if [ ! "$(command -v mp4info)" ]; then
  dc::logger::error "You need mp4info for this to work fully (part of bento)."
fi


# Argument 1 is mandatory and must be a readable file
dc::fs::isfile "$1"

filename="$1"
dc::logger::info "[movie-info] $filename"


info::ffprobe(){
  local comprobe=ffprobe
  # XXX avprobe is an entirely different thing, not implementing support for this s.

  local data
  local fast
  local duration
  local return

  dc::logger::debug "$comprobe -show_format -show_error -show_data -show_streams  -print_format json \"$1\" 2>/dev/null)"


  if ! data=$($comprobe -show_format -show_error -show_data -show_streams -print_format json "$1" 2>/dev/null) || [ "$(printf "%s" "$data" | jq -c .error)" != "null" ]; then
    # XXX review this to see what other info we should return (filesize?)
    dc::output::json "{\"file\":\"$1\"}"
    dc::logger::error "ffprobe is unable to analyze this file. Not a movie. Stopping here."
    exit "$ERROR_FAILED"
  fi

  if ! fast=$(mp4info --format json "$1" | jq -rc .file.fast_start 2>/dev/null); then
    dc::logger::error "mp4info errored out or is not available. faststart information will be inaccurate."
    fast=false
  fi

  duration=$(printf "%s" "$data" | jq '.format | select(.duration != null) | .duration | tonumber | floor')
  if [ ! "$duration" ]; then
    duration=0
  fi

  return=$(printf "%s" "$data" | jq --arg fast "$fast" --arg duration "$duration" -r '{
    file: .format.filename,
    size: .format.size,
    container: .format.format_name,
    description: .format.format_long_name,
    fast: $fast,
    duration: $duration,
    video: [
      .streams[] | select (.codec_type == "video") | {
        id: .index,
        codec: .codec_name,
        description: .codec_long_name,
        width: .width,
        height: .height
      }
    ],
    audio: [
      .streams[] | select (.codec_type == "audio") | {
        id: .index,
        codec: .codec_name,
        description: .codec_long_name,
        language: .tags.language
      }
    ],
    subtitles: [
      .streams[] | select (.codec_type == "subtitle") | {
        id: .index,
        codec: .codec_name,
        description: .codec_long_name,
        language: .tags.language
      }
    ],
    other: [
      .streams[] | select ((.codec_type == "video"|not) and (.codec_type == "audio"|not) and (.codec_type == "subtitle"|not))
    ]
  }')
  dc::logger::debug "Returned data: $return"
  dc::output::json "$return"
}

info::ffprobe "$filename"
