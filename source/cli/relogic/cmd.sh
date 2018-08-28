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
directory=$(basename "$1")
parent=$(dirname "$1")

parse::dirname(){
  local movie="$1"
#  imdbID=$(echo $movie | sed -E 's/[(]?[^(\[]*[(\[]tt([0-9]{7}).*/\1/')
  imdbID=$(echo $movie | sed -E 's/.*tt([0-9]{7}).*/\1/')
  ltitle=$(echo $movie | sed -E 's/[^ ]*[ -]+([^(\[]+).*/\1/')
  ltitle=${ltitle% *}
  quality=$(echo $movie | sed -E 's/.*\[(.*)\]/\1/')
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

  # Check if bonus
  local isBonus=$(echo $oldtitle | grep -I ^Bonus)
  if [ "$isBonus" ]; then
    newtitle="${oldtitle%.*}"
  fi
  local isAlternate=$(echo $oldtitle | grep -I ^Alternate)
  if [ "$isAlternate" ]; then
    newtitle="${oldtitle%.*}"
  fi

  local isPart=$(echo $oldtitle | grep ", part [0-9]")
  local isDisc=$(echo $oldtitle | grep ", disc [0-9]")
  local isEpisode=$(echo $oldtitle | grep -E "[,]? E[0-9][0-9]")

  local part=
  if [ ! "$isBonus" ] && [ ! "$isAlternate" ] && [ "$isPart" ]; then
    part=$(echo $oldtitle | sed -E 's/.*(, part [0-9]).*/\1/')
  fi
  local disc=
  if [ ! "$isBonus" ] && [ ! "$isAlternate" ] && [ "$isDisc" ]; then
    disc=$(echo $oldtitle | sed -E 's/.*(, disc [0-9]).*/\1/')
  fi
  local episode=
  if [ ! "$isBonus" ] && [ ! "$isAlternate" ] && [ "$isEpisode" ]; then
    episode=$(echo $oldtitle | sed -E 's/.*([,]? E[0-9]+).*/\1/')
  fi
  if [ ! "$isBonus" ] && [ ! "$isAlternate" ]; then
    if [ "$extension" == "srt" ] || [ "$extension" == "sub" ] || [ "$extension" == "idx" ] || [ "$extension" == "rar" ] || [ "$extension" == "ass" ] || [ "$extension" == "smi" ] || [ "$extension" == "sami" ]; then
      local ln=
      lnMatch=$(echo $oldtitle | grep -Ei "[, ._(-]+(?:chinese|chinese-traditional|croatian|danish|dutch|english|french|german|greek|hebrew|italian|japanese|polish|portuguese|russian|romanian|spanish|swedish|turkish|vietnamese|br|bra|chi|deu|de|dut|eng|en|esp|es|fra|fre|fr|ger|gre|hu|it|ita|nl|nwg|por|pt-br|ptb|ptbr|pt|ro|rum|spa|swe)[)]*.$extension")
      if [ ! "$lnMatch" ]; then
        dc::logger::error "No language for subtitle $oldname"
      else
        ln=$(echo $oldtitle | gsed -E 's/.+[, ._(-]+(chinese|chinese-traditional|croatian|danish|dutch|english|french|german|greek|hebrew|italian|japanese|polish|portuguese|russian|romanian|spanish|swedish|turkish|vietnamese|br|bra|chi|deu|de|dut|eng|en|esp|es|fra|fre|fr|ger|gre|hu|it|ita|nl|nwg|por|pt-br|ptb|ptbr|pt|ro|rum|spa|swe)[)]*\.[a-z0-9]+/.\1/i')
      fi
    fi
  fi
  # newname="$newtitle$part$disc${newquality}$ln.$extension"
  newname="$newtitle$part$disc$episode$ln.$extension"

  if [ "$newname" != "$oldname" ]; then
    dc::logger::info "     > $oldname"
    dc::logger::info "     > $newname"
    if [ -e "$parent/$newname" ]; then
      dc::logger::error "Destination already exist! Ignoring file!"
      return
    fi
    dc::prompt::confirm
    mv "$parent/$oldname" "$parent/$newname"

  fi
}

parse::newdirname(){
  local hm="$1"
  local oldname="$2"
  local quality="$3"
  local newname="($imdbYear) $imdbTitle [tt$imdbID$quality]"
  if [ "$newname" != "$oldname" ]; then
    dc::logger::info "| $oldname"
    dc::logger::info "| $newname"
    if [ -e "$parent/$newname" ]; then
      dc::logger::error "Destination already exist! Abort!"
      exit 1
    fi
    dc::prompt::confirm
    mv "$parent/$oldname" "$parent/$newname"
  fi
}




dc::logger::debug "$parent/$directory"
parse::dirname "$directory"

retrieveIMDB $imdbID


finalquality=
for i in "$1"/*; do
  if [ ! -f "$i" ]; then
    dc::logger::warning "Ignoring non file: $i"
    continue
  fi

  relogic::mkvinfo "$i"
  filename=$(basename "$i")

  if [ "$validatedDuration" ]; then
    validatedDuration=".[$validatedDuration]"
  fi
  parse::newfilename "$currentdir" "$filename" "$imdbTitle$validatedDuration" # "$mkvquality"

  ispart=$(echo $filename | grep ", part [2-9]")
  isdisc=$(echo $filename | grep ", disc [2-9]")
  if [ "$(echo $filename | grep -I ^Bonus)" ] || [ "$ispart" ] || [ "$isdisc" ]; then
    continue
  fi
  if [ "$mkvquality" ]; then
    finalquality="-${imdbLengths[@]}-$mkvquality"
  fi

done


parse::newdirname "$parent" "$directory" "$finalquality"


exit



















#echo "Dir: $directory"

#echo "Local: $imdbID | $ltitle | $quality"
#echo "Remot: $iyear | $ititle"

# dc::http::request https://www.imdb.com/title/tt$imdbID/ GET

exit





if [ -n "${DC_ARGV_ISO_NAME+x}" ]; then
  iname="$DC_ARGV_ISO_NAME"
else
  iname="$(basename $source)"
fi

dc::logger::info "Creating ISO $iname.iso with volume name $vname from $source"
dc::logger::debug hdiutil makehybrid -udf -udf-volume-name "$vname" -o "$iname.iso" "$source"

hdiutil makehybrid -udf -udf-volume-name "$vname" -o "$iname.iso" "$source"

if [ $? != 0 ]; then
  dc::logger::error "Failed to create ISO!"
  exit $ERROR_FAILED
fi

dc::logger::info "Done"





