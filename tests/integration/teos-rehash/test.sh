#!/usr/bin/env bash

testTeosSort(){
  [ "$(command -v ffprobe)" ] || startSkipping

  [ "$(command -v ffprobe)" ] || endSkipping
}
