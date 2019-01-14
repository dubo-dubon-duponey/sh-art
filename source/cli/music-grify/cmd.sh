#!/usr/bin/env bash

readonly CLI_VERSION="0.1.0"
readonly CLI_LICENSE="MIT License"
readonly CLI_DESC="because I never remember ffmpeg invocations"

# Initialize
dc::commander::initialize
dc::commander::declare::flag delete "" "optional" "delete original file after successful conversion if specified"
dc::commander::declare::flag destination ".+" "optional" "where to put the converted file - will default to the same directory if left unspecified"
dc::commander::declare::flag codec "^(alac|flac|mp3|mp3-v0|mp3-v2)$" "optional" "format to convert to - will default to ALAC if unspecified"
dc::commander::declare::arg 1 ".+" "" "filename" "audio file to be checked / converted"
# Start commander
dc::commander::boot
# Requirements
dc::require ffmpeg "-version" "3.0"

# Get argument and destination flag
filename="$DC_PARGV_1"
destination=${DC_ARGV_DESTINATION:-$(dirname "$filename")}

# Filename is mandatory and must be a readable file
dc::fs::isfile "$filename"

# Must be writable, and create if doesn't exist
dc::fs::isdir "$destination" writable create

# Process filename
filename=$(basename "$filename")
# extension="${filename##*.}"
filename="${filename%.*}"

# Alac by default
codec=${DC_ARGV_CODEC:-alac}

# Prepare command line
ar=( "-hide_banner" "-v" 8 "-i" "$DC_PARGV_1" "-vn" "-codec:a" )

# Process the codec
case "$(printf "%s" "$codec" | tr '[:upper:]' '[:lower:]')" in
  mp3)
    dc::logger::debug "Codec: MP3 320k"
    codec="libmp3lame -b:a 320k"
    finalextension=mp3
  ;;
  mp3-v0)
    dc::logger::debug "Codec: MP3 V0"
    codec="libmp3lame -q:a 0"
    finalextension=mp3
  ;;
  mp3-v2)
    dc::logger::debug "Codec: MP3 V2"
    codec="libmp3lame -q:a 2"
    finalextension=mp3
  ;;
  alac)
    dc::logger::debug "Codec: ALAC"
    codec="alac"
    finalextension=m4a
  ;;
  flac)
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
	  rm "$DC_PARGV_1"
  else
    dc::logger::info "Original file preserved"
  fi
fi
