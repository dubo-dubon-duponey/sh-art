#!/usr/bin/env bash

# XXX hard to test currently, because of the readonly variables
# Need to fork to a standalone binary
hardToTestBashAndGnuGrep(){
  # . source/core/a-base.sh
  _have_bash
  dc-tools::assert::notnull "bash is there" "$DC_DEPENDENCIES_V_BASH"
#  _GNUGREP
  _have_gnu_grep
}

