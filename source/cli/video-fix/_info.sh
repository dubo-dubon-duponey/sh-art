#!/usr/bin/env bash

media::qinfo(){
  VIDEO_COUNT=
  AUDIO_COUNT=
  MP4_VIDEO_COUNT=
  DTS_AUDIO_COUNT=
  AAC_AUDIO_COUNT=
  AC3_AUDIO_COUNT=
  VIDEO_CODECS=
  AUDIO_CODECS=
  CONTAINER=
  IS_A_MOVIE=

  dc::logger::debug "Analyzing: $1"

  local movieSize=$(ls -l "$1" | awk '{print $5}')

  dc::logger::debug "Size is $movieSize"

  local data=$(mkvmerge --identification-format json --identify "$1")
  # ffprobe -v error -show_entries stream=index,codec_name,codec_type "$1"

  if [ "$(echo $data | jq -r .tracks)" == "null" ]; then
    dc::logger::debug "No tracks in this file. Probably not a movie. Stopping here."
    return
  fi

  IS_A_MOVIE=true

  local duration=$(echo $data | jq -r .container.properties.duration)
  # XXX DUGGGG MKV
  if [ "$duration" != "null" ]; then
    duration=$(( $duration / 1000000 / 1000 ))
    dc::logger::debug "Duration (mkv): $duration"
  else
    local altduration=$(ffprobe "$1" 2>&1 | grep "  Duration:" | grep -v "N/A" | sed -E 's/[^:]+[: ]+([0-9:]+).*/\1/')
    if [ "$altduration" ]; then
      duration=$(echo "${altduration%%:*} * 3600" | bc)
      altduration=${altduration#*:}
      duration=$(echo "$duration + ${altduration%%:*} * 60" | bc)
      duration=$(echo "$duration + ${altduration#*:}" | bc)
      dc::logger::debug "Duration (ffprobe): $duration"
    else
      dc::logger::debug "Unable to get the duration for this file"
    fi
  fi

  VIDEO_COUNT=( $(echo $data | jq -r '.tracks[] | select (.type == "video") | .id ') )
  AUDIO_COUNT=( $(echo $data | jq -r '.tracks[] | select (.type == "audio") | .id ') )
  MP4_VIDEO_COUNT=( $(echo $data | jq -r '.tracks[] | select (.codec == "MPEG-4p10/AVC/h.264") | .id ') )
  AAC_AUDIO_COUNT=( $(echo $data | jq -r '.tracks[] | select (.codec == "AAC") | .id ') )
  DTS_AUDIO_COUNT=( $(echo $data | jq -r '.tracks[] | select (.codec == "DTS") | .id ') )
  AC3_AUDIO_COUNT=( $(echo $data | jq -r '.tracks[] | select (.codec == "AC-3") | .id ') )
  VIDEO_CODECS=( $(echo $data | jq -r '.tracks[] | select (.type == "video") | .codec') )
  AUDIO_CODECS=( $(echo $data | jq -r '.tracks[] | select (.type == "audio") | .codec') )
  SUBTITLE_CODECS=( $(echo $data | jq -r '.tracks[] | select (.type == "subtitles") | .codec') )
  CONTAINER=$(echo $data | jq -r '.container.type')
  echo $1
  echo $data | jq -r '.tracks[] | select (.type == "subtitles")'
  exit

#  echo $data | jq
}

# XXX TODO subtitles
# Get the subs: ffprobe -v error -show_entries stream=index,codec_name,codec_type input.mkv
# Extract them:
#ffmpeg -i input.mkv \
#-map 0:0 -c copy video.mkv \
#-map 0:1 -c copy audio0.oga \
#-map 0:2 -c copy audio1.oga \
#-map 0:3 -c copy audio2.oga \
#-map 0:4 -c copy subtitles.ass
# then ignore them with -sn

# VobSub SubRip/SRT SubStationAlpha
