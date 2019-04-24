#!/usr/bin/env bash

testIMDBBogusID(){
  if ! _=$(dc::require jq "--version" 1.5); then
    startSkipping
  fi
  result=$(dc-imdb -s "BOGUS")
  exit=$?
  dc-tools::assert::equal "bogus ID" "$exit" "$ERROR_ARGUMENT_INVALID"
  dc-tools::assert::equal "$result" ""
  if ! _=$(dc::require jq "--version" 1.5); then
    endSkipping
  fi
}

testIMDBNonExistentID(){
  if ! _=$(dc::require jq "--version" 1.5); then
    startSkipping
  fi

  result=$(dc-imdb -s "tt0000000")
  exit=$?
  dc-tools::assert::equal "bogus ID" "$exit" "$ERROR_NETWORK"
  dc-tools::assert::equal "$result" ""

  if ! _=$(dc::require jq "--version" 1.5); then
    endSkipping
  fi
}

testIMDBData(){
  if ! _=$(dc::require jq "--version" 1.5); then
    startSkipping
  fi
  result=$(dc-imdb -s "tt0000001" | jq -r -c .)
  exit=$?
  dc-tools::assert::equal "$exit" "0"
  dc-tools::assert::equal "$result" '{"title":"Carmencita","original":"Carmencita","picture":"https://m.media-amazon.com/images/M/MV5BZmUzOWFiNDAtNGRmZi00NTIxLWJiMTUtYzhkZGRlNzg1ZjFmXkEyXkFqcGdeQXVyNDE5MTU2MDE@._V1_.jpg","year":"1894","type":"video.movie","runtime":["1 min"],"ratio":"1.33 : 1","id":"tt0000001","properties":{"SOUND_MIX":"Silent","COLOR":"Black and White","FILM_LENGTH":"15.24 m","NEGATIVE_FORMAT":"35 mm (Eastman)","CINEMATOGRAPHIC_PROCESS":"Kinetoscope","PRINTED_FILM_FORMAT":"35 mm"}}'

  if ! _=$(dc::require jq "--version" 1.5); then
    endSkipping
  fi
}

testIMDBData2(){
  if ! _=$(dc::require jq "--version" 1.5); then
    startSkipping
  fi
  result=$(dc-imdb -s "tt0286486" | jq -r -c .)
  exit=$?
  dc-tools::assert::equal "$exit" "0"
  dc-tools::assert::equal "$result" '{"title":"The Shield","original":"The Shield","picture":"https://m.media-amazon.com/images/M/MV5BMTcwNzQwODI5NV5BMl5BanBnXkFtZTcwNzQxMjI5MQ@@._V1_.jpg","year":"2002–2008","type":"video.tv_show","runtime":["47 min"],"ratio":"1.33 : 1 (cropped US original broadcast version) 1.78 : 1 (international and Sony DVD aspect ratio)","id":"tt0286486","properties":{"SOUND_MIX":"Stereo","COLOR":"Color","CAMERA":"Arriflex 16 SR3, Angenieux HR Lenses Clairmont Cameras and Lenses Video (some scenes)","NEGATIVE_FORMAT":"16 mm (Kodak Vision 250D 7246, Vision 320T 7277, Vision 500T 7279) Video","CINEMATOGRAPHIC_PROCESS":"Super 16","PRINTED_FILM_FORMAT":"Video (NTSC)"}}'

  if ! _=$(dc::require jq "--version" 1.5); then
    endSkipping
  fi
}

testIMDBImage(){
  if ! _=$(dc::require jq "--version" 1.5); then
    startSkipping
  fi
  filename="$(dc::portable::mktemp dc::http::request)"
  dc-imdb -s --image=dump "tt0000001" > "$filename"
  exit=$?
  dc-tools::assert::equal "$exit" "0"
  fileinfo="$(file -b "$filename")"

  dc-tools::assert::equal "${fileinfo%%,*}" "JPEG image data"

  if ! _=$(dc::require jq "--version" 1.5); then
    endSkipping
  fi
}
