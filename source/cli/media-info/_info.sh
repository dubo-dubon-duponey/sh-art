#!/usr/bin/env bash

info::ffprobe(){
  dc::logger::debug "ffprobe -show_format -show_error -show_data -show_streams  -print_format json \"$1\" 2>/dev/null)"
  local data=$(ffprobe -show_format -show_error -show_data -show_streams  -print_format json "$1" 2>/dev/null)
  if [ $? != 0 ] || [ "$(echo $data | jq -c .error)" != "null" ]; then
    dc::output::json "{\"filesize\": \"$filesize\", \"file\":\"$1\"}"
    dc::logger::error "ffprobe is unable to analyze this file. Not a movie. Stopping here."
    exit $ERROR_FAILED
  fi

  local fast=$(mp4info --format json "$1" | jq -rc .file.fast_start 2>/dev/null)
  local duration=$(echo $data | jq '.format | select(.duration != null) | .duration | tonumber | floor')
  if [ ! "$duration" ]; then
    duration=0
  fi

  local return=$(echo $data | jq --arg fast "$fast" --arg duration "$duration" -r '{
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



xxx.info::mp4(){
  local filesize=$(ls -l "$1" | awk '{print $5}')
  dc::logger::debug "mp4info --format json \"$1\""
  local data=$(mp4info --format json "$1")

  if [ $? != 0 ] || [ "$(echo $data | jq -c .)" == "{}" ]; then
    dc::output::json "{\"filesize\": \"$filesize\", \"file\":\"$1\"}"
    dc::logger::error "mp4info is unable to analyze this file. Clearly not an mp4 movie. Stopping here."
    exit $ERROR_FAILED
  fi

  local return=$(echo $data | jq -r --arg file "$1" --arg filesize $filesize '{
    file: $file,
    container: "QuickTime/MP4",
    fast: .file.fast_start,
    duration: .movie.duration,
    filesize: $filesize,
    video: [
      .tracks[] | select (.type == "Video") | {
        id: .id,
        codec: (.sample_descriptions[].coding + "/" + .sample_descriptions[].coding_name),
        size: ((.display_width|tostring) + "x" + (.display_height|tostring))
      }
    ],
    audio: [
      .tracks[] | select (.type == "Audio") | {
        id: .id,
        codec: (.sample_descriptions[].coding + "/" + .sample_descriptions[].coding_name + "/" + .sample_descriptions[].object_type_name),
        language: .language
      }
    ],
    subtitles: [
      .tracks[] | select ((.type == "Subtitles") or (.type == "Text")) | {
        id: .id,
        codec: (.sample_descriptions[].coding + "/" + .sample_descriptions[].coding_name),
        language: .language
      }
    ],
    other: [
      .tracks[] | select ((.type == "Video"|not) and (.type == "Audio"|not) and (.type == "Subtitles"|not) and (.type == "Text"|not))
    ]
  }')
  dc::logger::info "Returned data: $return"
  dc::output::json "$return"
}

xxx.info(){

  local filesize=$(ls -l "$1" | awk '{print $5}')

  dc::logger::debug "mkvmerge --identification-format json --identify \"$1\""
  local data=$(mkvmerge --identification-format json --identify "$1")
  if [ $? != 0 ] || [ "$(echo $data | jq -r .container.recognized)" != "true" ] || [ "$(echo $data | jq .container.supported)" != "true" ]; then
    dc::output::json "{\"filesize\": \"$filesize\", \"file\":\"$1\"}"
    dc::logger::error "mkvmerge is unable to analyze this file. Probably not a movie. Stopping here."
    exit $ERROR_FAILED
  fi

  if [ "$(echo $data | jq -r .container.type)" == "QuickTime/MP4" ]; then
    info::mp4 "$1"
    return
  fi

  local duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$1" 2>/dev/null)
  if [ "$duration" == "N/A" ]; then
    duration=
  fi

  # Round it to the second
  if [ "$duration" ]; then
    duration=$(printf "%.0f" $duration)
  fi

  local return=$(echo $data | jq -r --arg duration "$duration" --arg file "$1" --arg filesize "$filesize" '{
    file: $file,
    container: .container.type,
    fast: "",
    duration: $duration,
    filesize: $filesize,
    video: [
      .tracks[] | select (.type == "video") | {
        id: .id,
        codec: .codec,
        size: .properties.pixel_dimensions
      }
    ],
    audio: [
      .tracks[] | select (.type == "audio") | {
        id: .id,
        codec: .codec,
        language: .properties.language
      }
    ],
    subtitles: [
      .tracks[] | select (.type == "subtitles") | {
        id: .id,
        codec: .codec,
        language: .properties.language
      }
    ],
    other: [
      .tracks[] | select (.type == "video"|not) | select (.type == "audio"|not) | select (.type == "subtitles"|not)
    ]
  }')

  dc::logger::info "Returned data: $return"
  dc::output::json "$return"
}


# XXX not that useful
xxx::bin::file(){
  dc::logger::debug "file -b \"$1\""

  local id=$(file -b "$1")
  local type=$(file -b --mime-type "$1")
  local encoding=$(file -b --mime-encoding "$1")
  local extension=( $(file -b --extension "$1" | tr "," " ") )
  if [ ${#extension[@]} == 0 ]; then
    extension=${extension[0]}
    if [ "$extension" == "???" ]; then
      extension=
    fi
  else
    extension=
  fi

  return="{\"id\": \"$id\", \"type\": \"$type\", \"encoding\": \"$encoding\", \"size\": \"$filesize\"}" # \"extension\": \"$extension\",  <- XXX USELESS on macOS?
  dc::logger::debug "Returning: $return"
  echo $return | jq
}

