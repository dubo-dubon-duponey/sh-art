#!/usr/bin/env bash

testKingpin(){
  local exitcode

  [ "$(uname)" == Darwin ] || startSkipping

  exitcode=0
  dc-kingpin -s "BOGUS" || exitcode=$?
  dc-tools::assert::equal ARGUMENT_INVALID "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc-kingpin -s "go" || exitcode=$?
  dc-tools::assert::equal NO_ERROR "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc-kingpin "node" || exitcode=$?
  dc-tools::assert::equal NO_ERROR "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc-kingpin -s "python" || exitcode=$?
  dc-tools::assert::equal NO_ERROR "$(dc::error::lookup $exitcode)"

  [ "$(uname)" == Darwin ] || endSkipping
}
