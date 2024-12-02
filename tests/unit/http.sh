#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

# Integration tests for dc-http cover enough already and more exhaustively
testSimpleHttp(){
  local exitcode

  exitcode=0
  # local output

  # XXX this is broken for some reason if shift fails in dc::http::request - -> WEIRD <-
  dc::http::request "https://www.google.com" || exitcode=$?

#  dc::http::dump::headers
  dc-tools::assert::equal "Successful HEAD" "0" "$exitcode"
}
