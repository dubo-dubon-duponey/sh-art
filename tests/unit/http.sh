#!/usr/bin/env bash

# Integration tests for dc-http cover enough already and more exhaustively
testSimpleHttp(){
  local result
  # local output
  dc::http::request "https://www.google.com"
  result=$?

#  dc::http::dump::headers
#  dc::http::dump::body
  dc-tools::assert::equal "Successful HEAD" "$result" "0"
}
