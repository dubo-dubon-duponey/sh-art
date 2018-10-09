#!/usr/bin/env bash

testLibre(){
  result=$(dc-libre dc::output::json "{}")
  exit=$?
  dc-tools::assert::equal "libre successful exit" "$exit" 0
  dc-tools::assert::equal "$result" "{}"
}

#. $_here/../../../bin/dc-libre --

#$_here/../../../bin/dc-libre dc::http::request https://registry-1.docker.io/v2 GET
#dc-tools::assert::equal ARGV_TEST1 foo
#dc-tools::assert::equal ARGV_TEST2 bar
#dc-tools::assert::equal ARGV_TEST3_TEST baz
#dc-tools::assert::equal ARGV_TEST4 be
#dc-tools::assert::null ARGV_IGNORE
#dc-tools::assert::null ARGV_IGNOREAGAIN
#dc-tools::assert::null ARGV_TEST5
#dc-tools::assert::null ARGV_TEST6
#dc-tools::assert::equal ARGV_TEST7 '""'
