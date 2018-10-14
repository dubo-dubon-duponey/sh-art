#!/usr/bin/env bash

testMovieGrify(){
  [ "$(command -v ffmpeg)" ] || startSkipping

  local result

  [ ! -f "tests/integration/movie-grify/movie.mp4" ] || rm "tests/integration/movie-grify/movie.mp4"
  result=$(DC_MOVIE_GRIFY_LOG_LEVEL=debug dc-movie-grify --destination=tests/integration/movie-grify --convert=1 --remove=1 tests/integration/movie-grify/movie.avi)
  local exit=$?
  dc-tools::assert::equal "$exit" "0"
  dc-tools::assert::equal "$result" ""

  [ ! -f "tests/integration/movie-grify/movie.mp4" ] || rm "tests/integration/movie-grify/movie.mp4"

  [ "$(command -v ffmpeg)" ] || endSkipping
}
