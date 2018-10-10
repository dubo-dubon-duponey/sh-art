#!/usr/bin/env bash

testMovieInfo(){
  [ "$(command -v ffprobe)" ] || startSkipping

  local result

  local expected='{"file":"tests/integration/movie-info/movie.m4v","size":"11312","container":"mov,mp4,m4a,3gp,3g2,mj2","description":"QuickTime / MOV","fast":"false","duration":"1","video":[{"id":0,"codec":"h264","description":"H.264 / AVC / MPEG-4 AVC / MPEG-4 part 10","width":558,"height":418}],"audio":[],"subtitles":[],"other":[]}'
  result=$(dc-movie-info -s tests/integration/movie-info/movie.m4v | jq -rc .)
  local exit=$?

  dc-tools::assert::equal "$exit" "0"
  dc-tools::assert::equal "$result" "$expected"

  expected='{"file":"tests/integration/movie-info/movie.mkv","size":"11402","container":"matroska,webm","description":"Matroska / WebM","fast":"null","duration":"1","video":[{"id":0,"codec":"h264","description":"H.264 / AVC / MPEG-4 AVC / MPEG-4 part 10","width":558,"height":418}],"audio":[{"id":1,"codec":"aac","description":"AAC (Advanced Audio Coding)","language":"eng"}],"subtitles":[],"other":[]}'
  result=$(dc-movie-info -s tests/integration/movie-info/movie.mkv | jq -rc .)
  local exit=$?

  dc-tools::assert::equal "$exit" "0"
  dc-tools::assert::equal "$result" "$expected"

  expected='{"file":"tests/integration/movie-info/movie.mov","size":"11323","container":"mov,mp4,m4a,3gp,3g2,mj2","description":"QuickTime / MOV","fast":"false","duration":"1","video":[{"id":0,"codec":"h264","description":"H.264 / AVC / MPEG-4 AVC / MPEG-4 part 10","width":558,"height":418}],"audio":[],"subtitles":[],"other":[]}'
  result=$(dc-movie-info -s tests/integration/movie-info/movie.mov | jq -rc .)
  local exit=$?

  dc-tools::assert::equal "$exit" "0"
  dc-tools::assert::equal "$result" "$expected"

  expected='{"file":"tests/integration/movie-info/movie.avi","size":"21462","container":"avi","description":"AVI (Audio Video Interleaved)","fast":"null","duration":"1","video":[{"id":0,"codec":"h264","description":"H.264 / AVC / MPEG-4 AVC / MPEG-4 part 10","width":558,"height":418}],"audio":[{"id":1,"codec":"aac","description":"AAC (Advanced Audio Coding)","language":null}],"subtitles":[],"other":[]}'
  result=$(dc-movie-info -s tests/integration/movie-info/movie.avi | jq -rc .)
  local exit=$?

  dc-tools::assert::equal "$exit" "0"
  dc-tools::assert::equal "$result" "$expected"

  [ "$(command -v ffprobe)" ] || endSkipping
}
