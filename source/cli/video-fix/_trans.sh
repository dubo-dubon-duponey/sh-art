#!/usr/bin/env bash

xxxtransmogrify::do(){
  local filename="$1"
  local destination="$2"
  local audioidconvert=$3
  local audioremovelist=( $4 )

  local ar=( "ffmpeg" "-i" "$1" "-map" "0" "-c" "copy" ) # "$2"

  # If we need to remove stuff, do it
  local i
  for i in $audioremovelist; do
    ar[${#ar[@]}]="-map"
    ar[${#ar[@]}]="-0:a:$i"
  done

  # If there is one track to convert, go for it
  if [ "$audioidconvert" ]; then
    ar[${#ar[@]}]="-map"
    ar[${#ar[@]}]="0:a:$audioidconvert"
    ar[${#ar[@]}]="-c:a:0"
    ar[${#ar[@]}]="libfdk_aac"
    ar[${#ar[@]}]="-b:a"
    ar[${#ar[@]}]="256k"
  fi
}


xxxtranscode::container(){
  dc::logger::info "Repacking file"
  local ar=( "ffmpeg" "-i" "$1" "-map" "0" "-c" "copy" "$2" )
  dc::logger::debug "${ar[@]}"
  "${ar[@]}"
}
# MPEG-4p10/AVC/h.264

xxxtranscode::container+audio(){
  local keep_old_stream=$3
  local mapper="-c:a"
  local message="Repacking file, converting audio stream into AAC"
  if [ "$keep_old_stream" ]; then
    mapper="$mapper:0"
    message="$message, preserving existing audio stream"
  fi
  dc::logger::info "$message"
  local ar=( "ffmpeg" "-i" "$1" "-map" "0" "-c" "copy" "-map" "0:a" "$mapper" "libfdk_aac" "-b:a" "256k" "$2" )
  dc::logger::debug "${ar[@]}"
  dc::prompt::confirm
  "${ar[@]}"
}

xxxtranscode::fullmonthy(){
  dc::logger::info "Full Monty this!"
  local ar=( "HandBrakeCLI" "--preset" "Fast 1080p30" "-i" "$1" "-o" "$2" )
  dc::logger::debug "${ar[@]}"
  dc::prompt::confirm
  "${ar[@]}"
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
