#!/usr/bin/env bash

testKingpin(){
  local exitcode

  [ "$(uname)" == Darwin ] || startSkipping

  exitcode=0
  dc-kingpin -s "BOGUS" || exitcode=$?
  dc-tools::assert::equal ARGUMENT_INVALID "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc-kingpin "go" || exitcode=$?
  dc-tools::assert::equal NO_ERROR "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc-kingpin "node" || exitcode=$?
  dc-tools::assert::equal NO_ERROR "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc-kingpin "python" || exitcode=$?
  dc-tools::assert::equal NO_ERROR "$(dc::error::lookup $exitcode)"

  [ "$(uname)" == Darwin ] || endSkipping
}
