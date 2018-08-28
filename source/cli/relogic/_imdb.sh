#!/usr/bin/env bash

retrieveIMDB(){
  local imdbID=$1

  local idCheck=$(echo $imdbID | grep [^0-9])
  if [ -z "$imdbID" -o -n "$idCheck" ];
  then
    dc::logger::error "Bogus ID! $imdbID"
    exit 1
  fi

  imdbTitle=$(curl --stderr /dev/null https://www.imdb.com/title/tt$imdbID/)
  local imdbLength=$(echo $imdbTitle | grep -i "runtime:" | sed -E 's/.*Runtime:(([^<]+|<[^\/<]+|<\/[^d][^<]+)*)<\/div>.+/\1/')
  imdbTitle=$(echo $imdbTitle | sed -E 's/.*<title>([^<]*)- IMDb.*/\1/')

#  imdbYear=$(echo $imdbTitle | sed -E 's/.*[(].*([0-9]{4})[)].*/\1/')
#  imdbTitle=$(echo $imdbTitle | sed -E 's/(.*)[(].*[0-9]{4}[)]/\1/')
  imdbYear=$(echo $imdbTitle | sed -E 's/.*[(][^)]*([0-9]{4}[–0-9]*)[ ]*[)].*/\1/')
  imdbTitle=$(echo $imdbTitle | sed -E 's/(.*)[(][^)]*[0-9]{4}[–0-9]*[ ]*[)].*/\1/')

  imdbTitle=$(echo $imdbTitle | sed "s/&#x27;/'/g")
  imdbTitle=$(echo $imdbTitle | sed "s/&#xB0;/°/g")
  imdbTitle=$(echo $imdbTitle | sed "s/&#xC0;/A/g")
  imdbTitle=$(echo $imdbTitle | sed "s/&#xC7;/C/g")
  imdbTitle=$(echo $imdbTitle | sed 's/&#xE7;/c/g')
  imdbTitle=$(echo $imdbTitle | sed 's/&#xE8;/e/g')
  imdbTitle=$(echo $imdbTitle | sed 's/&#xE9;/e/g')
  imdbTitle=$(echo $imdbTitle | sed 's/&#xEA;/e/g')
  imdbTitle=$(echo $imdbTitle | sed "s/&#xE0;/a/g")
  imdbTitle=$(echo $imdbTitle | sed "s/&#xE2;/a/g")
  imdbTitle=$(echo $imdbTitle | sed "s/&#xEE;/i/g")
  imdbTitle=$(echo $imdbTitle | sed "s/&#xEF;/i/g")
  imdbTitle=$(echo $imdbTitle | sed "s/&#xFB;/u/g")
  imdbTitle=$(echo $imdbTitle | sed "s/&#xF4;/o/g")
  imdbTitle=$(echo $imdbTitle | sed "s/&#xF6;/o/g")
  imdbTitle=$(echo $imdbTitle | sed "s/&#xF9;/u/g")
  imdbTitle=$(echo $imdbTitle | sed 's/&quot;/"/g')
  imdbTitle=$(echo $imdbTitle | sed 's/&ndash;/-/g')
  imdbTitle=$(echo $imdbTitle | sed 's/&amp;/&/g')
  imdbTitle=$(echo $imdbTitle | sed 's/&nbsp;/ /g')
  imdbTitle=$(echo $imdbTitle | sed 's/&#x26;/&/g')
  imdbTitle=$(echo $imdbTitle | sed 's/&#xEF;/i/g')
  imdbTitle=$(echo $imdbTitle | sed 's/[\\(\\)]//g')
  imdbTitle=$(echo $imdbTitle | sed 's/â/a/g')
  imdbTitle=$(echo $imdbTitle | sed 's/à/a/g')
  imdbTitle=$(echo $imdbTitle | sed 's/á/a/g')
  imdbTitle=$(echo $imdbTitle | sed 's/ä/a/g')
  imdbTitle=$(echo $imdbTitle | sed 's/Â/A/g')
  imdbTitle=$(echo $imdbTitle | sed 's/À/A/g')
  imdbTitle=$(echo $imdbTitle | sed 's/Ä/A/g')
  imdbTitle=$(echo $imdbTitle | sed 's/ç/c/g')
  imdbTitle=$(echo $imdbTitle | sed 's/é/e/g')
  imdbTitle=$(echo $imdbTitle | sed 's/è/e/g')
  imdbTitle=$(echo $imdbTitle | sed 's/ê/e/g')
  imdbTitle=$(echo $imdbTitle | sed 's/ë/e/g')
  imdbTitle=$(echo $imdbTitle | sed 's/î/i/g')
  imdbTitle=$(echo $imdbTitle | sed 's/ï/i/g')
  imdbTitle=$(echo $imdbTitle | sed 's/ô/o/g')
  imdbTitle=$(echo $imdbTitle | sed 's/ö/o/g')
  imdbTitle=$(echo $imdbTitle | sed 's/ó/o/g')
  imdbTitle=$(echo $imdbTitle | sed 's/û/u/g')
  imdbTitle=$(echo $imdbTitle | sed 's/ü/u/g')
  imdbTitle=$(echo $imdbTitle | sed 's/ú/u/g')
  imdbTitle=$(echo $imdbTitle | sed 's/\//:/g')

  imdbLengths=()

  if [ ! "$imdbLength" ]; then
    return
  fi

  imdbLength=$(echo $imdbLength | sed -E 's/(<[^>]+>)//g' | sed -E 's/( min)//g')
  while true; do
    local sub=$(echo ${imdbLength%%|*} | sed 's/([ ]+)//g')
    imdbLengths[${#imdbLengths[@]}]=$(echo $sub | tr '/' ':')
    #imdbLengths[${#imdbLengths[@]}]=$(awk '{$sub=$sub};1')
    # imdbLengths[${#imdbLengths[@]}]=${imdbLength%%|*}
    if [ "$imdbLength" == "${imdbLength#*|}" ]; then
      break
    fi
    imdbLength=${imdbLength#*|}
  done


}
