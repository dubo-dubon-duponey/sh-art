#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

testLibre(){
  local exitcode
  exitcode=0
  result=$(dc-libre dc::output::json "{}") || exitcode=$?
  dc-tools::assert::equal "libre successful exit" "$exitcode" 0
  dc-tools::assert::equal "$result" "{}"
}

#. $_here/../../.dc-libre --

#$_here/../../.dc-libre dc::http::request https://registry-1.docker.io/v2 GET
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
  local exitcode

  "$@" 1>/dev/null 2>&1 &
  pid=$!
  printf "%s\n" "$pid"
  wait "$pid" || exitcode=$?
  printf "%s\n" "$exitcode"
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
    done < <(commandWrapper "dc-libre" "--help" "--$signal" 2>/dev/null)
    dc-tools::assert::equal "signal handling $signal" "$ex" "$x"
  done
}

helperTestErr(){
  local expected="$1"
  local set="$2"
  shift
  shift
  local pid=""
  local ex
  local args=()
  [ ! "$set" ] || args+=("--set=$set")
  args+=("$@")

  while read -r line; do
    if [ ! "$pid" ]; then
      pid="$line"
      continue
    fi
    ex="$line"
  done < <(commandWrapper "dc-libre" "${args[@]}" 2>/dev/null)
  dc-tools::assert::equal "exit code for $*" "$expected" "$(dc::error::lookup "$ex")"
}

testVariousConditions(){
  helperTestErr SYSTEM_GENERIC_ERROR "" let "var1 = 1/0"
  # Only works with bash3 - bash4 gives exit 1
  helperTestErr SYSTEM_SHELL_BUILTIN_MISUSE "" printf -f
  helperTestErr SYSTEM_COMMAND_NOT_EXECUTABLE "+e" /dev/null
  helperTestErr SYSTEM_COMMAND_NOT_FOUND "" thisfails
  # Bash4&5 gives SYSTEM_SHELL_BUILTIN_MISUSE instead
  bv="$(dc::internal::version::get bash)"
  if [ "${bv%.*}" == 3 ]; then
    helperTestErr SYSTEM_EXIT_OUT_OF_RANGE "" exit a3.14
  else
    helperTestErr SYSTEM_SHELL_BUILTIN_MISUSE "" exit a3.14
  fi
  helperTestErr SYSTEM_EXIT_OUT_OF_RANGE "" exit 511
#  helperTestErr SYSTEM_INVALID_EXIT_ARGUMENT <- no way to do this with bash?
}


# 1
# dc-libre let "var1 = 1/0"

# 2
# dc-libre printf

# 126
# dc-libre --set="+e" /dev/null

# 127
# dc-libre thisfails

# 255
# dc-libre exit 3.14

