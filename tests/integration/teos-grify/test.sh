#!/usr/bin/env bash

testMovieGrify(){
  command -v ffmpeg >/dev/null || startSkipping

  #local result

  [ ! -f "tests/integration/teos-grify/movie.mp4" ] || rm "tests/integration/teos-grify/movie.mp4"
  #result=$(dc-teos-grify -s --destination=tests/integration/teos-grify tests/integration/teos-grify/movie.avi)
  local exit=$?
  dc-tools::assert::equal "$exit" "0"
  #dc-tools::assert::equal "$result" ""

  [ ! -f "tests/integration/teos-grify/movie.mp4" ] || rm "tests/integration/teos-grify/movie.mp4"

  command -v ffmpeg >/dev/null || endSkipping
}
