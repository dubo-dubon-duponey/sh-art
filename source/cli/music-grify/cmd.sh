#!/usr/bin/env bash

readonly CLI_VERSION="0.0.1"
readonly CLI_LICENSE="MIT License"
readonly CLI_DESC="because I never remember ffmpeg invocation"
readonly CLI_USAGE="[-s] [--delete/-d] [--destination=folder] [--codec=ALAC|FLAC|MP3|MP3-VO|MP3-V2] filename"

# Boot
dc::commander::init

if ! command -v ffmpeg >/dev/null; then
  dc::logger::error "You need ffmpeg for this to work."
  exit "$ERROR_MISSING_REQUIREMENTS"
fi

filename="$1"

# Argument 1 is mandatory and must be a readable file
dc::fs::isfile "$filename"

# Destination
# dc::argv::flag::validate destination
destination=${DC_ARGV_DESTINATION:-$(dirname "$filename")}

# Must be writable, and create if doesn't exist
dc::fs::isdir "$destination" writable create

# Process filename
filename=$(basename "$filename")
# extension="${filename##*.}"
filename="${filename%.*}"

# Validate codec if present
if [ "$DC_ARGE_CODEC" ]; then
  dc::argv::flag::validate codec "^(alac|flac|mp3|mp3-v0|mp3-v2)$" "-Ei"
fi

# Alac by default
codec=${DC_ARGV_CODEC:-ALAC}

# Prepare command line
ar=( "-hide_banner" "-v" 8 "-i" "$1" "-vn" "-codec:a" )

# Process the codec
case "$(printf "%s" "$codec" | tr '[:lower:]' '[:upper:]')" in
  MP3)
    dc::logger::debug "Codec: MP3 320k"
    codec="libmp3lame -b:a 320k"
    finalextension=mp3
  ;;
  MP3-V0)
    dc::logger::debug "Codec: MP3 V0"
    codec="libmp3lame -q:a 0"
    finalextension=mp3
  ;;
  MP3-V2)
    dc::logger::debug "Codec: MP3 V2"
    codec="libmp3lame -q:a 2"
    finalextension=mp3
  ;;
  ALAC)
    dc::logger::debug "Codec: ALAC"
    finalextension=m4a
  ;;
  FLAC)
    dc::logger::debug "Codec: FLAC"
    codec="flac -compression_level 8"
    finalextension=flac
  ;;
esac

for i in $codec; do
  ar[${#ar[@]}]="$i"
done

# Add the file
ar[${#ar[@]}]="$destination/$filename.$finalextension"

# If the file already exists, stop here
if [ -f "$destination/$filename.$finalextension" ]; then
  dc::logger::error "Destination file already exist. Aborting!"
  exit "$ERROR_FAILED"
fi

dc::logger::info "Transcoding $filename to $destination/$filename.$finalextension using settings: $codec"

# Go for it
dc::logger::debug "ffmpeg ${ar[*]}"
if ! ffmpeg "${ar[@]}"; then
	dc::logger::error "Failed to convert $filename!"
	if [ -f "$destination/$filename.$finalextension" ]; then
  	rm "$destination/$filename.$finalextension"
	fi
	exit "$ERROR_FAILED"
else
	dc::logger::info "Success"
  if [ "$DC_ARGE_DELETE" ] || [ "$DC_ARGE_D" ]; then
    dc::logger::info "Original file deleted"
	  rm "$1"
  else
    dc::logger::info "Original file preserved"
  fi
fi
