#!/usr/bin/env bash

for i in ubuntu-lts-old ubuntu-lts-current ubuntu-current ubuntu-next alpine-current alpine-next debian-old debian-current debian-next; do
  if ! DOCKERFILE=./dckr.Dockerfile TARGET="$i" dckr make test; then
    echo "FAILED"
    exit 1
  fi
done
