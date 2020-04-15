#!/usr/bin/env bash

a(){
  echo | echo
  cat $1
}

b(){
  echo
  cat $1
}

c(){
  tput op
  cat $1
}

d(){
  local _
  _=$(echo | echo)
  cat $1
}

e(){
  local _
  _=$(tput op)
  cat $1
}

_f(){
  local _
  _=$(true)
}

f(){
  _f
  cat $1
}

_g(){
  local _
  tput op
}

g(){
  _g
  cat $1
}

_h(){
  local _
  printf "foo\n"
}

h(){
  _h
  cat $1
}

_i(){
  local _
  tput op
}

i(){
  local _
  _=$(_i)
  cat $1
}

_j(){
  true
}

j(){
  _j
  cat $1
}

k(){
  local _

  local x=5
  while [ "$x" -gt 0 ]; do
    x=$((x - 1))
  done

  cat $1
}

# 3.2.57 macOS fails on two occasions
# 4.3.11
# 4.3.30
# 4.3.48
# 4.4.19 (alpine)
# 4.4.12
# 4.4.20
# 5.0.0 (alpine)
# 5.0.3
# 5.0.11 (alpine)
# 5.0.16 fails on one occasion
testNamedPipes(){
  local exitcode
  local bv
  local is5016=""

  bv="$(dc::internal::version::get bash)"
  if bash --version | grep -q 5.0.16; then
    is5016=true
  fi

  dc::logger::warning "Bash version: $(bash --version)"
  >&2 cat /etc/issue 2>/dev/null || true

  exitcode=0
  a <(printf "1\n") || exitcode=10
  if [ "${bv%.*}" == 3 ]; then
    dc-tools::assert::equal "Pipe with builtins" 10 "$exitcode"
  else
    dc-tools::assert::equal "Pipe with builtins" 0 "$exitcode"
  fi


  exitcode=0
  b <(printf "2\n") || exitcode=10
  dc-tools::assert::equal "Builtin" 0 "$exitcode"

  exitcode=0
  c <(printf "3\n") || exitcode=10
  if [ "${bv%.*}" == 3 ]; then
    dc-tools::assert::equal "External binary" 10 "$exitcode"
  else
    dc-tools::assert::equal "External binary" 0 "$exitcode"
  fi

  exitcode=0
  d <(printf "4\n") || exitcode=10
  dc-tools::assert::equal "Subshell with pipe and builtin" 0 "$exitcode"

  exitcode=0
  e <(printf "5\n") || exitcode=10
  dc-tools::assert::equal "Subshell with external binary" 0 "$exitcode"

  exitcode=0
  f <(printf "6\n") || exitcode=10
  # 5.0.16 fails
  if [ "$is5016" ]; then
    dc-tools::assert::equal "Function with subshell and builtin" 10 "$exitcode"
  else
    dc-tools::assert::equal "Function with subshell and builtin" 0 "$exitcode"
  fi

  exitcode=0
  g <(printf "7\n") || exitcode=10
  if [ "${bv%.*}" == 3 ] || [ "$is5016" ]; then
    dc-tools::assert::equal "Function with external binary" 10 "$exitcode"
  else
    dc-tools::assert::equal "Function with external binary" 0 "$exitcode"
  fi

  exitcode=0
  h <(printf "8\n") || exitcode=10
  dc-tools::assert::equal "Function with builtin" 0 "$exitcode"

  exitcode=0
  i <(printf "9\n") || exitcode=10
  dc-tools::assert::equal "Wrapped function with builtin" 0 "$exitcode"

  exitcode=0
  j <(printf "10\n") || exitcode=10
  dc-tools::assert::equal "Wrapped function doing nothing" 0 "$exitcode"

  return

  # XXX somehow, the while in wrapped grep was breaking, but this is not reproducing for some reason...
  exitcode=0
  k <(printf "11\n") || exitcode=10
  if [ "${bv%.*}" == 3 ] || [ "$is5016" ]; then
    dc-tools::assert::equal "Function with external binary" 10 "$exitcode"
  else
    dc-tools::assert::equal "Function with external binary" 0 "$exitcode"
  fi

}

testStdin(){
  local exitcode
  local bv
  local is5016=""

  bv="$(dc::internal::version::get bash)"
  if bash --version | grep -q 5.0.16; then
    is5016=true
  fi

  dc::logger::warning "Bash version: $(bash --version)"
  >&2 cat /etc/issue 2>/dev/null || true

  exitcode=0
  a /dev/stdin <<<"1\n" || exitcode=10
  dc-tools::assert::equal "Pipe with builtins" 0 "$exitcode"

  exitcode=0
  b /dev/stdin <<<"2\n" || exitcode=10
  dc-tools::assert::equal "Builtin" 0 "$exitcode"

  exitcode=0
  c /dev/stdin <<<"3\n" || exitcode=10
  dc-tools::assert::equal "External binary" 0 "$exitcode"

  exitcode=0
  d /dev/stdin <<<"4\n" || exitcode=10
  dc-tools::assert::equal "Subshell with pipe and builtin" 0 "$exitcode"

  exitcode=0
  e /dev/stdin <<<"5\n" || exitcode=10
  dc-tools::assert::equal "Subshell with external binary" 0 "$exitcode"

  exitcode=0
  f /dev/stdin <<<"6\n" || exitcode=10
  # 5.0.16 fails
  dc-tools::assert::equal "Function with subshell and builtin" 0 "$exitcode"

  exitcode=0
  g /dev/stdin <<<"7\n" || exitcode=10
  dc-tools::assert::equal "Function with external binary" 0 "$exitcode"

  exitcode=0
  h /dev/stdin <<<"8\n" || exitcode=10
  dc-tools::assert::equal "Function with builtin" 0 "$exitcode"

  exitcode=0
  i /dev/stdin <<<"9\n" || exitcode=10
  dc-tools::assert::equal "Wrapped function with builtin" 0 "$exitcode"
}
