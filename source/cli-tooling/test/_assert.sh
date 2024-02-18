#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

dc-tools::assert::null(){
  local ex
  assertNull "$@" || {
    ex=$?
    echo "=============================================================================================="
    echo "Error details:"
    dc::error::detail::get
    echo
    echo "=============================================================================================="
    exit "$ex"
  }
}

dc-tools::assert::notnull(){
  assertNotNull "$@" || {
    ex=$?
    echo "=============================================================================================="
    echo "Error details:"
    dc::error::detail::get
    echo
    echo "=============================================================================================="
    exit "$ex"
  }
}

dc-tools::assert::equal(){
  local ex
  assertEquals "$@" || {
    ex=$?
    echo "=============================================================================================="
    echo "Error details:"
    dc::error::detail::get
    echo
    echo "=============================================================================================="
    exit "$ex"
  }
}

dc-tools::assert::notequal(){
  assertNotEquals "$@" || {
    ex=$?
    echo "=============================================================================================="
    echo "Error details:"
    dc::error::detail::get
    echo
    echo "=============================================================================================="
    exit "$ex"
  }
}

dc-tools::assert::contains(){
  assertContains "$@" || {
    ex=$?
    echo "=============================================================================================="
    echo "Error details:"
    dc::error::detail::get
    echo
    echo "=============================================================================================="
    exit "$ex"
  }
}
