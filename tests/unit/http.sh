#!/usr/bin/env bash

. source/lib/http.sh

# Integration tests for dc-http cover enough already and more exhaustively
testSimpleHttp(){
  local exitcode

  exitcode=0
  # local output
  dc::http::request "https://www.google.com" || exitcode=$?

#  dc::http::dump::headers
#  dc::http::dump::body
  dc-tools::assert::equal "Successful HEAD" "0" "$exitcode"
}
