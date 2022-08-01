#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

dc-tools::assert::null(){
  assertNull "$@"
}

dc-tools::assert::notnull(){
  assertNotNull "$@"
}

dc-tools::assert::equal(){
  assertEquals "$@"
}

dc-tools::assert::notequal(){
  assertNotEquals "$@"
}

dc-tools::assert::contains(){
  assertContains "$@"
}
