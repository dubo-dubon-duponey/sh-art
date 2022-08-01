#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

dc::logger::error "LAME! NO TEST!"

test(){
  true
}
