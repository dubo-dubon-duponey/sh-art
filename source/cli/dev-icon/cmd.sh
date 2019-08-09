#!/usr/bin/env bash

true
# shellcheck disable=SC2034
readonly CLI_DESC="makes macos and windows icons out of a png file"

# Initialize
dc::commander::initialize
dc::commander::declare::flag preserve "^$" "do not delete intermediary files" optional p
dc::commander::declare::arg 1 ".+" "image" "the path to the png image to use"
dc::commander::boot

# Requirements
dc::require::platform::mac
dc::require sips
dc::require iconutil
dc::require convert "" "" "You should: brew install imagemagick"
dc::require icotool "" "" "You should: brew install icoutils"

original="$DC_PARGV_1"
dc::fs::isfile "$original"

if [ "$(file -b --mime "$original")" != "image/png; charset=binary" ]; then
  dc::logger::error "File $original is not a png image. Reported mime-type: $(file -b --mime "$original")"
  exit "$ERROR_ARGUMENT_INVALID"
fi

convert "$original" -define png:color-type=6 "$(basename "$original")"
original="$(basename "$original")"

destination="$(pwd)/${original%.*}.iconset"
mkdir -p "$destination"

sipIt(){
	source="$1"
	dest="$2"
	size="$3"
	qualifier="$4"
	if [ ! "$qualifier" ]; then
		qualifier="${size}x${size}"
	fi
	sips -z "$size" "$size" "$source" --out "$dest/icon_$qualifier.png" > /dev/null
}

for i in 16 32 128 256 512; do
	sipIt "$original" "$destination" "$i"
done

sipIt "$original" "$destination" "32" "16x16@2x"
sipIt "$original" "$destination" "64" "32x32@2x"
sipIt "$original" "$destination" "256" "128x128@2x"
sipIt "$original" "$destination" "512" "256x256@2x"
sipIt "$original" "$destination" "1024" "512x512@2x"

iconutil -c icns "$destination"

windows(){
  local original="$1"
  local base
  base="${original%.*}"

  convert "$original" -thumbnail 16x16 "${base}_16.png"
  convert "$original" -thumbnail 32x32 "${base}_32.png"
  convert "$original" -thumbnail 48x48 "${base}_48.png"
  convert "$original" -thumbnail 64x64 "${base}_64.png"

  icotool -c -o "${base}".ico "${base}"_{16,32,48,64}.png
}

windows "$original"

if [ ! "$DC_ARGE_PRESERVE" ] && [ ! "$DC_ARGE_P" ]; then
  rm "$original"
  rm -Rf "$destination"
  rm "${original%.*}_"*
fi

dc::logger::info "Done!"
dc::logger::info " > $(file "$(pwd)/${original%.*}.icns")"
dc::logger::info " > $(file "$(pwd)/${original%.*}.ico")"
