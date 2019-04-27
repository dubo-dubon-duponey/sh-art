#!/usr/bin/env bash

for i in ubuntu-lts-previous ubuntu-lts-current ubuntu-next alpine-current debian-current debian-next; do
  DOCKERFILE=./dckr.Dockerfile TARGET="$i" dckr make test 2>/dev/null
done
