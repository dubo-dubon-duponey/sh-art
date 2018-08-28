#!/usr/bin/env sh

#ui::debug_on(){
#  DEBUG=on
#}

ui::stamp(){
  echo "[$(date)] $@"
}

ui::debug(){
  if [ ! -z "$DEBUG" ]; then
    local i
    for i in "$@"; do
      ui::stamp "[DEBUG]" "$i"
    done
  fi
}

ui::text(){
  local i
  for i in "$@"; do
    echo "$i"
  done
}

ui::info(){
  [ -z "$TERM" ] || tput setaf 2
  local i
  for i in "$@"; do
    ui::stamp "[INFO]" "$i"
  done
  [ -z "$TERM" ] || tput op
}

ui::warning(){
  [ -z "$TERM" ] || tput setaf 3
  local i
  for i in "$@"; do
    ui::stamp "[WARNING]" "$i"
  done
  [ -z "$TERM" ] || tput op
}


ui::error(){
  [ -z "$TERM" ] || tput setaf 1
  local i
  for i in "$@"; do
    ui::stamp "[ERROR]" "$i"
  done
  [ -z "$TERM" ] || tput op
  exit 1
}

ui::code(){
  local i
  for i in "$@"; do
    echo "    \$ $i"
  done
}

ui::section(){
  [ -z "$TERM" ] || tput setaf 2
  echo "_____________________________________________________________________________"
  local i
  for i in "$@"; do
    echo -n "| "
    printf "%*s" $(( ( $(echo "$i" | wc -c ) + 76 ) / 2 )) "$i"
    printf "%*s\n" $(( 75 - ( $(echo "$i" | wc -c ) + 76 ) / 2 )) "|"
  done
  echo "_____________________________________________________________________________"
  [ -z "$TERM" ] || tput op
  echo ""
}

ui::header(){
  [ -z "$TERM" ] || tput setaf 2
  echo "★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★"
  local i
  for i in "$@"; do
    echo -n "★ "
    printf "%*s" $(( ( $(echo "$i" | wc -c ) + 76 ) / 2 )) "$i"
    printf "%*s\n" $(( 75 - ( $(echo "$i" | wc -c ) + 76 ) / 2 )) "★"
  done
  echo "★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★"
  [ -z "$TERM" ] || tput op
  echo ""
}
