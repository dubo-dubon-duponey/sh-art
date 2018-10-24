#!/usr/bin/env bash

testMusicGrify(){
#  -s --destination=folder --codec=ALAC|FLAC|MP3|MP3-VO|MP3-V2 filename
  if ! _=$(dc::require ffmpeg "-version" 3.0); then
    startSkipping
  fi

  local result

  [ ! -f "tests/integration/music-grify/music.mp3" ] || rm "tests/integration/music-grify/music.mp3"
  [ ! -f "tests/integration/music-grify/music.flac" ] || rm "tests/integration/music-grify/music.flac"
  [ ! -f "tests/integration/music-grify/music.m4a" ] || rm "tests/integration/music-grify/music.m4a"

  result=$(dc-music-grify --destination=tests/integration/music-grify --codec=flac tests/integration/music-grify/music.wav)
  local exit=$?
  dc-tools::assert::equal "$exit" "0"
  dc-tools::assert::equal "$result" ""
  [ ! -f "tests/integration/music-grify/music.flac" ] || rm "tests/integration/music-grify/music.flac"

  result=$(dc-music-grify --destination=tests/integration/music-grify --codec=alac tests/integration/music-grify/music.wav)
  local exit=$?
  dc-tools::assert::equal "$exit" "0"
  dc-tools::assert::equal "$result" ""
  [ ! -f "tests/integration/music-grify/music.m4a" ] || rm "tests/integration/music-grify/music.m4a"

  result=$(dc-music-grify --destination=tests/integration/music-grify --codec=mp3 tests/integration/music-grify/music.wav)
  local exit=$?
  dc-tools::assert::equal "$exit" "0"
  dc-tools::assert::equal "$result" ""
  [ ! -f "tests/integration/music-grify/music.mp3" ] || rm "tests/integration/music-grify/music.mp3"

  result=$(dc-music-grify --destination=tests/integration/music-grify --codec=mp3-v0 tests/integration/music-grify/music.wav)
  local exit=$?
  dc-tools::assert::equal "$exit" "0"
  dc-tools::assert::equal "$result" ""
  [ ! -f "tests/integration/music-grify/music.mp3" ] || rm "tests/integration/music-grify/music.mp3"

  result=$(dc-music-grify --destination=tests/integration/music-grify --codec=mp3-v2 tests/integration/music-grify/music.wav)
  local exit=$?
  dc-tools::assert::equal "$exit" "0"
  dc-tools::assert::equal "$result" ""
  [ ! -f "tests/integration/music-grify/music.mp3" ] || rm "tests/integration/music-grify/music.mp3"

  if ! _=$(dc::require ffmpeg "-version" 3.0); then
    endSkipping
  fi
}
