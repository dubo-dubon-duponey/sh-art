#!/usr/bin/env bash

# ffmpeg useful documentation: https://trac.ffmpeg.org/wiki/Encode/AAC

readonly CLI_VERSION="0.1.0"
readonly CLI_LICENSE="MIT License"
readonly CLI_DESC="because I never remember how to use ffmpeg"

# Initialize
dc::commander::initialize
dc::commander::declare::flag destination ".+" optional "where to put the converted file - will default to the same directory if left unspecified"
dc::commander::declare::flag delete "" optional "delete original file after successful conversion if specified"
dc::commander::declare::flag convert "^[0-9]$" optional "track identifier to convert to AAC (typically, an audio track)"
dc::commander::declare::flag remove "^[0-9]+( [0-9]+)*$" optional "one or many (space separated) track identifiers to remove"
dc::commander::declare::flag extract "^[0-9]+:[^ ]+( [0-9]+:[^ ]+)*$" optional "one or many (space separated) streams to extract on the side, with their final format (eg: 4:en.sub)"
dc::commander::declare::arg 1 ".+" "" "filename" "media file to process"
dc::commander::boot

# Requirements
dc::require ffmpeg "-version" "3.0"

# Argument 1 is mandatory and must be a readable file
dc::fs::isfile "$DC_PARGV_1"

filename=$(basename "$DC_PARGV_1")
# extension="${filename##*.}"
filename="${filename%.*}"

# Optional destination must be a writable directory - create it if not there
if [ "$DC_ARGV_DESTINATION" ]; then
  dc::fs::isdir "$DC_ARGV_DESTINATION" writable create
  destination="$DC_ARGV_DESTINATION/$filename"
else
  destination="$(dirname "$DC_PARGV_1")/$filename-convert"
fi


# Add -movflags faststart for web optimized shit
transmogrify::do(){
  local filename="$1"
  local destination="$2"
  local audconvert=$3
  local removelist
  read -r -a removelist< <(printf "%s" "$4")
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
  for i in "${removelist[@]}"; do
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
    for i in "$@"; do
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

  dc::logger::debug "${ar[*]}"
  "${ar[@]}" 2>/dev/null
}

xxxtranscode::fullmonthy(){
  dc::logger::info "Full Monty this!"
  local ar=( "HandBrakeCLI" "--preset" "Fast 1080p30" "-i" "$1" "-o" "$2" )
  dc::logger::debug "${ar[@]}"
  dc::prompt::confirm
  "${ar[@]}"
}






if ! transmogrify::do "$DC_PARGV_1" "$destination" "${DC_ARGV_CONVERT}" "${DC_ARGV_REMOVE}" "${DC_ARGV_EXTRACT}"; then
  dc::logger::error "Failed to convert $filename!"
  if [ -f "$destination.mp4" ]; then
    rm "$destination.mp4"
  fi
  exit "$ERROR_FAILED"
fi

dc::logger::info "Successfully transmogrified $DC_PARGV_1"
if [ "$DC_ARGE_DELETE" ] || [ "$DC_ARGE_D" ]; then
  dc::logger::info "Press enter to delete the original"
  dc::prompt::confirm
  rm "$DC_PARGV_1"
  dc::logger::info "Original deleted"
else
  dc::logger::info "Original preserved"
fi
