#!/usr/bin/env bash

testTeosSort(){
  command -v ffprobe >/dev/null || startSkipping

#  local result
#  local expected

#  rm -Rf "tests/integration/teos-rehash/for test (tt0000001)"
#  cp -R "tests/integration/teos-rehash/something (tt0000001)" "tests/integration/teos-rehash/for test (tt0000001)"
#  expected='{"file":"tests/integration/movie-info/movie.avi","size":"21462","container":"avi","description":"AVI (Audio Video Interleaved)","fast":"false","duration":"1","video":[{"id":0,"codec":"h264","description":"H.264 / AVC / MPEG-4 AVC / MPEG-4 part 10","width":558,"height":418}],"audio":[{"id":1,"codec":"aac","description":"AAC (Advanced Audio Coding)","language":null}],"subtitles":[],"other":[]}'
#  result=$(dc-teos-rehash -s "tests/integration/teos-rehash/for test (tt0000001)")
#  local exit=$?

#  dc-tools::assert::equal "$exit" "0"
#  dc-tools::assert::equal "$result" "$expected"

  command -v ffprobe >/dev/null || endSkipping
}
