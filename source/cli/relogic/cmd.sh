#!/usr/bin/env bash

readonly CLI_VERSION="0.0.1"
readonly CLI_LICENSE="MIT License"
readonly CLI_DESC="fancy movies organizer"
readonly CLI_USAGE="[-s] [--insecure] [--no-network] source-directory"

# Boot
dc::commander::init

# Argument 1 is mandatory and must be a readable directory
dc::fs::isdir "$1"

currentdir="$1"
directory="$(basename "$1")"
parent="$(dirname "$1")"

dc::logger::info "Processing $directory"

# Extract id from directory
imdbID="$(printf "%s" "$directory" | sed -E 's/.*(tt[0-9]{7}).*/\1/')"

# Fetch data
if ! imdb=$(./debug imdb "$imdbID"); then
  dc::logger::error "Could not retrieve information from imdb for id $imdbID and directory $directory. Aborting!"
  exit "$ERROR_FAILED"
fi

imdbYear="$(printf "%s" "$imdb" | jq -rc .year)"
imdbTitle="$(printf "%s" "$imdb" | jq -rc .title)"
imdbOriginal="$(printf "%s" "$imdb" | jq -rc .original)"

IFS=$'\n' read -r -d '' -a imdbRuntime < <(printf "%s" "$imdb" | jq -rc .runtime[])


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
  if grep -q -I "^Bonus" "$filename" || grep -q -I "^Alternate" "$filename"; then
    newtitle="${oldtitle%.*}"
  fi

  local part=
  local disc=
  # For non bonus & non alternate, snif out parts, discs and episodes
  if ! grep -q -I "^Bonus" "$filename" && ! grep -q -I "^Alternate" "$filename"; then
    if grep -q ", part [2-9]" "$filename"; then
      part="$(printf "%s" "$oldtitle" | sed -E 's/.*(, part [0-9]).*/\1/')"
    fi
    if grep -q ", disc [2-9]" "$filename"; then
      disc="$(printf "%s" "$oldtitle" | sed -E 's/.*(, disc [0-9]).*/\1/')"
    fi
    local episode=
    if grep -q "[,]? E[0-9][0-9]" "$filename"; then
      episode="$(printf "%s" "$oldtitle" | sed -E 's/.*([,]? E[0-9]+).*/\1/')"
    fi
    if [ "$extension" == "srt" ] || [ "$extension" == "sub" ] || [ "$extension" == "idx" ] || [ "$extension" == "rar" ] || [ "$extension" == "ass" ] || [ "$extension" == "smi" ] || [ "$extension" == "sami" ]; then
      local ln=
      lnMatch="$(printf "%s" "$oldtitle" | grep -Ei "[, ._(-]+(?:chinese|chinese-traditional|croatian|danish|dutch|english|french|german|greek|hebrew|italian|japanese|polish|portuguese|russian|romanian|spanish|swedish|turkish|vietnamese|br|bra|chi|deu|de|dut|eng|en|esp|es|fra|fre|fr|ger|gre|hu|it|ita|nl|nwg|por|pt-br|ptb|ptbr|pt|ro|rum|spa|swe)[)]*.$extension")"
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

