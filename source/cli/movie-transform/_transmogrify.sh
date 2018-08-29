#!/usr/bin/env bash

# Add -movflags faststart for web optimized shit
transmogrify::do(){
  local filename="$1"
  local destination="$2"
  local audconvert=$3
  local removelist=( $4 )
  shift
  shift
  shift
  shift

  # By default, copy all streams
#  local ar=( "ffmpeg" "-i" "$filename" "-movflags" "+faststart" "-map" "0" "-c" "copy" )
  local ar=( "ffmpeg" "-i" "$filename" "-movflags" "faststart" "-map" "0" "-c" "copy" )

  # And remove all subs
  # ar[${#ar[@]}]="-sn"

  # Now, remove the stuff in removelist
  local i
  for i in ${removelist[@]}; do
    ar[${#ar[@]}]="-map"
    ar[${#ar[@]}]="-0:$i"
  done

  # If there is an audio track to convert, go for it
  if [ "$audconvert" ]; then
    ar[${#ar[@]}]="-map"
    ar[${#ar[@]}]="0:$audconvert"
    ar[${#ar[@]}]="-c:a:0"
    ar[${#ar[@]}]="libfdk_aac"
    ar[${#ar[@]}]="-b:a"
    ar[${#ar[@]}]="256k"
  fi

  # Then output
  ar[${#ar[@]}]="$destination.mp4"

  # Now, do we have anything to extract? "id:suffix id:suffix"
  if [ "$1" ]; then
    for i in $@; do
      ar[${#ar[@]}]="-map"
      ar[${#ar[@]}]="0:${i%:*}"
      #ar[${#ar[@]}]="-c"
      #ar[${#ar[@]}]="copy"
      ar[${#ar[@]}]="$destination.${i#*:}"

      # XXX mov_text tx3g is not well supported by media players at this point it seems.
      # For now, extract all subtitles instead
      #ar[${#ar[@]}]="-map"
      #ar[${#ar[@]}]="0:${i%:*}"
      #ar[${#ar[@]}]="mov_text"
      #ar[${#ar[@]}]="-tag:s:$i" #-tag:s:s:0
      #ar[${#ar[@]}]="tx3g"
    done
  fi

  local debug="${ar[@]}"
  dc::logger::debug "$debug"
  "${ar[@]}" 2>/dev/null
}
