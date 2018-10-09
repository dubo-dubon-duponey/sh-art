#!/usr/bin/env bash

info::ffprobe(){
  local data
  local fast
  local duration
  local return

  dc::logger::debug "ffprobe -show_format -show_error -show_data -show_streams  -print_format json \"$1\" 2>/dev/null)"


  if ! data=$(ffprobe -show_format -show_error -show_data -show_streams -print_format json "$1" 2>/dev/null) || [ "$(printf "%s" "$data" | jq -c .error)" != "null" ]; then
    # XXX review this to see what other info we should return (filesize?)
    dc::output::json "{\"file\":\"$1\"}"
    dc::logger::error "ffprobe is unable to analyze this file. Not a movie. Stopping here."
    exit "$ERROR_FAILED"
  fi

  fast=$(mp4info --format json "$1" | jq -rc .file.fast_start 2>/dev/null)
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
