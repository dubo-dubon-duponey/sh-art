#!/usr/bin/env bash

readonly CLI_VERSION="0.0.1"
readonly CLI_LICENSE="MIT License"
readonly CLI_DESC="because I never remember how to use ffmpeg"
readonly CLI_USAGE="[-s] [--destination=folder] [--delete] [--convert=X] [--remove=X Y Z] [--extract=X:ln.ext Y:ln.ext Z:ln.ext] filename"

# Boot
dc::commander::init

if [ ! "$(command -v ffmpeg)" ]; then
  dc::logger::error "You need ffmpeg for this to work."
  exit "$ERROR_MISSING_REQUIREMENTS"
fi

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
