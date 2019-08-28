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

commandWrapper(){
  local pid

  "$@" 1>/dev/null 2>&1 &
  pid=$!
  printf "%s\n" "$pid"
  wait "$pid"
  printf "%s\n" "$?"
}

testSignals(){
  local pid
  local ex
  local signal
  local x=127
  # SIGINT and SIGQUIT are not testable in that context https://unix.stackexchange.com/questions/356408/strange-problem-with-trap-and-sigint
  for signal in "" "SIGHUP" "" "" "" "" "SIGABRT" "" "" "SIGKILL" "" "" "" "" "SIGALRM" "SIGTERM"; do
    x=$(( x + 1 ))
    if [ ! "$signal" ]; then
      continue
    fi
    pid=
    ex=
    while read -r line; do
      if [ ! "$pid" ]; then
        pid="$line"
        kill -s "$signal" "$pid"
        continue
      fi
      ex="$line"
    done < <(commandWrapper "./bin/bootstrap" "--help" "--$signal" 2>/dev/null)
    dc-tools::assert::equal "signal handling $signal" "$ex" "$x"
  done
}

# XXX Need to instrument dc-libre for that when this gets moved to sh-art
# 1 - caught by ERR
# let "var1 = 1/0"
# ls -lA /goo

# 2 - NOT caught by ERR
# empty_function() {}

# 126 - caught by err
# /dev/null

# 127 - caught by err
# thisfails

# 128
# XXX not sure how to do this
# exit "3.14"

# 255
# apparently, bash does $ex % 255 so out of range never triggers...
# exit 257
