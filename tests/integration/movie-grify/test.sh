#!/usr/bin/env bash

testMovieGrify(){
  [ "$(command -v ffmpeg)" ] || startSkipping

  local result

  [ ! -f "tests/integration/movie-grify/movie.mp4" ] || rm "tests/integration/movie-grify/movie.mp4"
#  ffmpeg -i tests/integration/movie-grify/movie.avi -movflags faststart -map 0 -c copy -map -0:1 -map 0:1 -c:a:0 libfdk_aac -b:a 256k tests/integration/movie-grify/movie.mp4

  # [ ! -f "tests/integration/movie-grify/movie.mp4" ] || rm "tests/integration/movie-grify/movie.mp4"
  # XXX remove conversion for libfdk_aac is not on linuxes --convert=1
  result=$(DC_MOVIE_GRIFY_LOG_LEVEL=debug dc-movie-grify --destination=tests/integration/movie-grify --remove=1 tests/integration/movie-grify/movie.avi)
  local exit=$?
  dc-tools::assert::equal "$exit" "0"
  dc-tools::assert::equal "$result" ""

  [ ! -f "tests/integration/movie-grify/movie.mp4" ] || rm "tests/integration/movie-grify/movie.mp4"

  [ "$(command -v ffmpeg)" ] || endSkipping
}
