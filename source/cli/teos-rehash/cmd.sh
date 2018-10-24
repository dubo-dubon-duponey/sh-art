#!/usr/bin/env bash

readonly CLI_VERSION="0.0.1"
readonly CLI_LICENSE="MIT License"
readonly CLI_DESC="movies filesystem organizer"
readonly CLI_USAGE="[-s] [--insecure] source-directory"

# Boot
dc::commander::initialize
dc::commander::declare::arg 1 ".+" "" "directory" "the directory to analyze. The name must contain an imdb identifier (eg: tt0000001)"
# Start commander
dc::commander::boot

# Requirements
dc::require dc-imdb
dc::require dc-movie-info

# Argument 1 is mandatory and must be a readable directory
dc::fs::isdir "$1"

currentdir="$1"
directory="$(basename "$1")"
parent="$(dirname "$1")"

dc::logger::info "Processing $directory"

# Extract id from directory
imdbID="$(printf "%s" "$directory" | sed -E 's/.*(tt[0-9]{7}).*/\1/')"

# Fetch data
if ! imdb=$(dc-imdb "$imdbID"); then
  dc::logger::error "Could not retrieve information from imdb for id $imdbID and directory $directory. Aborting!"
  exit "$ERROR_FAILED"
fi

imdbYear="$(printf "%s" "$imdb" | jq -r -c .year)"
imdbTitle="$(printf "%s" "$imdb" | jq -r -c .title)"
imdbOriginal="$(printf "%s" "$imdb" | jq -r -c .original)"

IFS=$'\n' read -r -d '' -a imdbRuntime < <(printf "%s" "$imdb" | jq -r -c .runtime[])

relogic::mkvinfo(){
  local file="$1"
  shift
  local data
  data="$(dc-movie-info -s "$file")"

  mkvquality=

  if [ ! "$(printf "%s" "$data" | jq -r -c '.duration')" ]; then
    return
  fi
  if [ "$(printf "%s" "$data" | jq -r -c '.duration')" == 0 ]; then
    return
  fi
  if [ "$(printf "%s" "$data" | jq -r -c '.video[0].width')" == "null" ]; then
    return
  fi

  local duration

  # echo $data
  # echo "in"
  #dc::output::json "$data"
  mkvquality="$(printf "%s" "$data" | jq -r -c '.video[] | "(" + (.id|tostring) + ")-" + .codec + "-" + (.width|tostring) + "x" + (.height|tostring)')"
  mkvquality="$mkvquality-$(printf "%s" "$data" | jq -r -c '.audio[] | "(" + (.id|tostring) + ")-" + .codec + "-" + .language')"
  duration="$(printf "%s" "$data" | jq -r -c '(.size|tonumber) / (.duration|tonumber) / .video[0].width / .video[0].height')"
  duration="$(printf "%s\\n" "scale=2;$duration/1" | bc)"
  mkvquality="$mkvquality-$duration"

  local c
  local w
  local h
  c="$(printf "%s" "$data" | jq -r -c '.video[] | .codec')"
  w="$(printf "%s" "$data" | jq -r -c '.video[] | (.width|tostring)')"
  h="$(printf "%s" "$data" | jq -r -c '.video[] | (.height|tostring)')"
  if [ "$c" == "h264" ]; then
    if [ "$h" -le 500 ] && [ "$w" -le 600 ]; then
      dc::logger::error "This movie is h264 but LD: $file"
    elif [ "$h" -le 576 ] || [ "$w" -le 720 ]; then
      dc::logger::warning "This movie is h264 but MD: $file"
    else
      dc::logger::info "This movie is h264 and HD: $file"
    fi
  else
    if [ "$h" -le 500 ] && [ "$w" -le 600 ]; then
      dc::logger::error "This movie is NOT h264 ($c) and LD: $file"
    elif [ "$h" -le 576 ] || [ "$w" -le 720 ]; then
      dc::logger::warning "This movie is NOT h264 ($c) and MD: $file"
    else
      dc::logger::warning "This movie is NOT h264 ($c) but it's HD: $file"
    fi
  fi

  local checkDuration
  local i
  local delta=0
  local jitter=0
  local matching

  checkDuration="$(printf "%s" "$data" | jq -r -c '(.duration|tonumber) / 60 | floor')"
  for i in "$@"; do
    #echo "> $i"
    #echo "> $checkDuration"
    delta=$(printf "%s\\n" "scale=0;$checkDuration - ${i%% min*}" | bc)
    jitter=$(printf "%s\\n" "scale=0;($checkDuration - ${i%% min*}) * 100 / ${i%% min*}" | bc)

    if { [ "$delta" -ge 2 ] || [ "$delta" -le -2 ]; } && { [ "$jitter" -ge 2 ] || [ "$jitter" -le -2 ]; }; then
      dc::logger::warning "Moving on"
    else
      matching="$i"
      # XXX no simple way for now to store it in
      # validatedDuration=$checkDuration:$i
      break
    fi
  done

  if [ "$matching" ]; then
    dc::logger::info "With local duration $checkDuration, found a decent match with version: $matching"
  else
    dc::logger::error "Could not resolve movie duration $checkDuration to available runtimes: $*}"
  fi

  dc::logger::debug "Estimated quality: [$mkvquality]"
}

parse::newfilename(){
  local parent="$1"
  local oldname="$2"
  local newtitle="$3"
  # local newquality="$4"
  local extension="${oldname##*.}"
  # Leave images and pdf alone
  if [ "$extension" == "png" ] || [ "$extension" == "jpg" ] || [ "$extension" == "pdf" ] || [ "$extension" == "gif" ]; then
    return
  fi

  # Discard quality from existing oldname
  local oldtitle="$oldname" #"$(echo $oldname | sed -E 's/( [^\[]+).*/\1/')"

  # Check if bonus or alternate and in that case, don't touch
  if grep -q -I "^Bonus" "$parent/$oldname" || grep -q -I "^Alternate" "$parent/$oldname"; then
    newtitle="${oldtitle%.*}"
  fi

  local part=
  local disc=
  local episode=
  local ln=
  # For non bonus & non alternate, snif out parts, discs and episodes
  if ! grep -q -I "^Bonus" "$parent/$oldname" && ! grep -q -I "^Alternate" "$parent/$oldname"; then
    if grep -q ", part [2-9]" "$parent/$oldname"; then
      part="$(printf "%s" "$oldtitle" | sed -E 's/.*(, part [0-9]).*/\1/')"
    fi
    if grep -q ", disc [2-9]" "$parent/$oldname"; then
      disc="$(printf "%s" "$oldtitle" | sed -E 's/.*(, disc [0-9]).*/\1/')"
    fi
    if grep -q "[,]? E[0-9][0-9]" "$parent/$oldname"; then
      episode="$(printf "%s" "$oldtitle" | sed -E 's/.*([,]? E[0-9]+).*/\1/')"
    fi

    if [ "$extension" == "srt" ] || [ "$extension" == "sub" ] || [ "$extension" == "idx" ] || [ "$extension" == "rar" ] || [ "$extension" == "ass" ] || [ "$extension" == "smi" ] || [ "$extension" == "sami" ]; then
      lnMatch="$(printf "%s" "$oldtitle" | grep -Ei "[, ._(-]+(chinese|chinese-traditional|croatian|danish|dutch|english|french|german|greek|hebrew|italian|japanese|polish|portuguese|russian|romanian|spanish|swedish|turkish|vietnamese|br|bra|chi|deu|de|dut|eng|en|esp|es|fra|fre|fr|ger|gre|hu|it|ita|nl|nwg|por|pt-br|ptb|ptbr|pt|ro|rum|spa|swe)[)]*.$extension")"
      if [ ! "$lnMatch" ]; then
        dc::logger::error "No language for subtitle $oldname"
      else
        ln="$(printf "%s" "$oldtitle" | gsed -E 's/.+[, ._(-]+(chinese|chinese-traditional|croatian|danish|dutch|english|french|german|greek|hebrew|italian|japanese|polish|portuguese|russian|romanian|spanish|swedish|turkish|vietnamese|br|bra|chi|deu|de|dut|eng|en|esp|es|fra|fre|fr|ger|gre|hu|it|ita|nl|nwg|por|pt-br|ptb|ptbr|pt|ro|rum|spa|swe)[)]*\.[a-z0-9]+/.\1/i')"
      fi
    fi
  fi

  # newname="$newtitle$part$disc${newquality}$ln.$extension"
  newname="$newtitle$part$disc$episode$ln.$extension"

  if [ "$newname" != "$oldname" ]; then
    dc::logger::warning "     < $oldname"
    dc::logger::warning "     > $newname"
    if [ -e "$parent/$newname" ]; then
      dc::logger::error "Destination already exist! Ignoring file!"
      return
    fi
    dc::prompt::confirm
    mv "$parent/$oldname" "$parent/$newname"
  fi
}

parse::newdirname(){
  local parent="$1"
  local oldname="$2"
  local id="$3"
  local year="$4"
  local title="$5"
  local quality="$6"
  local newname="($year) $title [$id$quality]"
  if [ "$newname" != "$oldname" ]; then
    dc::logger::warning "< $oldname"
    dc::logger::warning "> $newname"
    if [ -e "$parent/$newname" ]; then
      dc::logger::error "Destination already exist! Abort!"
      exit 1
    fi
    dc::prompt::confirm
    mv "$parent/$oldname" "$parent/$newname"
  fi
}

finalquality=

# XXX don't forget to reimplement filesystem safe escaping

runtime=$(printf "%s" "${imdbRuntime[*]}" | sed -E 's/ min//g')

mkvquality=

for i in "$1"/*; do
  if [ ! -f "$i" ]; then
    dc::logger::warning "Ignoring non file: $i"
    continue
  fi

  relogic::mkvinfo "$i" "${imdbRuntime[@]}"
  filename=$(basename "$i")

  if [ "$validatedDuration" ]; then
    validatedDuration=".[$validatedDuration]"
  fi

  parse::newfilename "$currentdir" "$filename" "$imdbTitle$validatedDuration"

  if grep -q -I ^Bonus "$filename" || grep -q ", part [2-9]" "$filename" || grep -q ", disc [2-9]" "$filename"; then
    continue
  fi
  if [ "$mkvquality" ]; then
    finalquality="-$runtime-$mkvquality"
  fi

done


# Finally, rename the directory
if [ "$imdbOriginal" == "$imdbTitle" ]; then
  imdbOriginal=
else
  imdbOriginal=" ($imdbOriginal)"
fi
newname="($imdbYear) $imdbTitle$imdbOriginal [$imdbID$finalquality]"
if [ "$newname" != "$directory" ]; then
  dc::logger::info "< $directory"
  dc::logger::info "> $newname"
  if [ -e "$parent/$newname" ]; then
    dc::logger::error "Destination already exist! Abort!"
    exit 1
  fi
  dc::prompt::confirm
  mv "$parent/$directory" "$parent/$newname"
fi

