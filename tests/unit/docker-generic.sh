#!/usr/bin/env bash

. source/headers/docker.sh
. source/headers/types.sh
. source/lib/docker.sh

testDockerCommand() {
  local exitcode

  exitcode=0
  dc::wrapped::docker bogus_command || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} bogus command error" "DOCKER_WRONG_COMMAND" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::wrapped::docker network || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} incomplete command" "DOCKER_WRONG_SYNTAX" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::wrapped::docker inspect nonexistentbs >/dev/null || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} non existent object" "DOCKER_NO_SUCH_OBJECT" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::wrapped::docker network ls >/dev/null || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} no error" "NO_ERROR" "$(dc::error::lookup $exitcode)"
}

testDockerInfo() {
  local exitcode

  exitcode=0
  docker::info > /dev/null || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} docker info no error" "NO_ERROR" "$(dc::error::lookup $exitcode)"

  exitcode=0
  docker::host dmp localhost 22
  docker::info > /dev/null || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} docker info no error" "BINARY_UNKNOWN_ERROR" "$(dc::error::lookup $exitcode)"
}

