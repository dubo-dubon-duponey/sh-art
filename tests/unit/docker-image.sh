#!/usr/bin/env bash

. source/headers/docker.sh
. source/headers/types.sh
. source/lib/docker.sh

testDockerImageLookup() {
  local result
  local exitcode

  if ! command -v docker > /dev/null; then
    return
  fi

  [ "$HOME" != /home/dckr ] || startSkipping

  docker pull debian:buster-slim > /dev/null || true
  docker pull busybox@sha256:afe605d272837ce1732f390966166c2afff5391208ddd57de10942748694049d > /dev/null || true

  exitcode=0
  docker::image::lookup nonexistent latest || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} non existent image name" "DOCKER_NO_SUCH_OBJECT" "$(dc::error::lookup $exitcode)"

  exitcode=0
  docker::image::lookup busybox nonexistent || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} non existent tag" "DOCKER_NO_SUCH_OBJECT" "$(dc::error::lookup $exitcode)"

  exitcode=0
  docker::image::lookup busybox "" "sha256:foo" || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} non existent digest" "DOCKER_NO_SUCH_OBJECT" "$(dc::error::lookup $exitcode)"

  exitcode=0
  result="$(docker::image::lookup debian buster-slim)" || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} valid image" "NO_ERROR" "$(dc::error::lookup $exitcode)"
  dc-tools::assert::notnull "${FUNCNAME[0]} image id 1" "$result"

  exitcode=0
  result="$(docker::image::lookup busybox "" sha256:afe605d272837ce1732f390966166c2afff5391208ddd57de10942748694049d)" || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} valid image by digest" "NO_ERROR" "$(dc::error::lookup $exitcode)"
  dc-tools::assert::notnull "${FUNCNAME[0]} image id 2" "$result"

  [ "$HOME" != /home/dckr ] || endSkipping
}

testDockerImageInspect() {
  local result
  local exitcode

  if ! command -v docker > /dev/null; then
    return
  fi

  [ "$HOME" != /home/dckr ] || startSkipping

  docker pull debian:buster-slim > /dev/null || true
  docker pull busybox@sha256:afe605d272837ce1732f390966166c2afff5391208ddd57de10942748694049d > /dev/null || true

  exitcode=0
  docker::image::inspect nonexistent latest > /dev/null || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} non existent image name" "DOCKER_NO_SUCH_OBJECT" "$(dc::error::lookup $exitcode)"

  exitcode=0
  docker::image::inspect busybox nonexistent > /dev/null || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} non existent tag" "DOCKER_NO_SUCH_OBJECT" "$(dc::error::lookup $exitcode)"

  exitcode=0
  docker::image::inspect busybox "" "sha256:foo" > /dev/null || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} non existent digest" "DOCKER_NO_SUCH_OBJECT" "$(dc::error::lookup $exitcode)"

  exitcode=0
  result="$(docker::image::inspect debian buster-slim | jq -rc ".[0].Architecture")" || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} valid image" "NO_ERROR" "$(dc::error::lookup $exitcode)"
  dc-tools::assert::equal "${FUNCNAME[0]} image inspection 1" "amd64" "$result"

  exitcode=0
  result="$(docker::image::inspect busybox "" sha256:afe605d272837ce1732f390966166c2afff5391208ddd57de10942748694049d | jq -rc ".[0].Architecture")" || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} valid image by digest" "NO_ERROR" "$(dc::error::lookup $exitcode)"
  dc-tools::assert::equal "${FUNCNAME[0]} image inspection 2" "amd64" "$result"

  [ "$HOME" != /home/dckr ] || endSkipping
}

testDockerImageRemove() {
  local result
  local exitcode

  if ! command -v docker > /dev/null; then
    return
  fi

  [ "$HOME" != /home/dckr ] || startSkipping

  docker pull debian:buster-slim > /dev/null || true
  docker pull busybox@sha256:afe605d272837ce1732f390966166c2afff5391208ddd57de10942748694049d > /dev/null || true

  exitcode=0
  docker::image::remove nonexistent latest > /dev/null || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} non existent image name" "DOCKER_NO_SUCH_OBJECT" "$(dc::error::lookup $exitcode)"

  exitcode=0
  docker::image::remove busybox nonexistent > /dev/null || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} non existent tag" "DOCKER_NO_SUCH_OBJECT" "$(dc::error::lookup $exitcode)"

  # XXX sha should be validated before it hits docker and fail
  exitcode=0
  docker::image::remove busybox "" "sha256:foo" > /dev/null || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} non existent digest" "BINARY_UNKNOWN_ERROR" "$(dc::error::lookup $exitcode)"

  # This is a random invalid sha
  exitcode=0
  docker::image::remove busybox "" "sha256:9155b85d83d6f4a9076b9890c8f9b57cd5987d7a02e015d24d6bb0661e671fdc" > /dev/null || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} non existent digest" "DOCKER_NO_SUCH_OBJECT" "$(dc::error::lookup $exitcode)"

  exitcode=0
  docker::image::remove debian buster-slim || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} valid image" "NO_ERROR" "$(dc::error::lookup $exitcode)"
  dc::error::detail::get

  exitcode=0
  docker::image::remove busybox "" sha256:afe605d272837ce1732f390966166c2afff5391208ddd57de10942748694049d || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} valid image by digest" "NO_ERROR" "$(dc::error::lookup $exitcode)"

  [ "$HOME" != /home/dckr ] || endSkipping
}

testDockerPull(){
  local result
  local exitcode

  if ! command -v docker > /dev/null; then
    return
  fi

  [ "$HOME" != /home/dckr ] || startSkipping

  exitcode=0
  docker::image::pull nonexistent latest > /dev/null || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} non existent image name" "DOCKER_NO_SUCH_OBJECT" "$(dc::error::lookup $exitcode)"

  exitcode=0
  docker::image::pull busybox nonexistent > /dev/null || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} non existent tag" "DOCKER_NO_SUCH_OBJECT" "$(dc::error::lookup $exitcode)"

  # XXX sha should be validated before it hits docker and fail
  exitcode=0
  docker::image::pull busybox "" "sha256:foo" > /dev/null || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} non existent digest" "DOCKER_NO_SUCH_OBJECT" "$(dc::error::lookup $exitcode)"

  # This is a random invalid sha
  exitcode=0
  docker::image::pull busybox "" "sha256:9155b85d83d6f4a9076b9890c8f9b57cd5987d7a02e015d24d6bb0661e671fdc" > /dev/null || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} non existent digest" "DOCKER_NO_SUCH_OBJECT" "$(dc::error::lookup $exitcode)"

  [ "$HOME" != /home/dckr ] || endSkipping
}

