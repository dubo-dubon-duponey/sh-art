#!/usr/bin/env bash

dc-tools::sc::list(){
  git ls-tree -r HEAD | grep -E '^1007|.*\..*sh$' | awk '{print $4}' | grep -v tests
}

dc-tools::sc::isShell() {
	head -n1 "$1" | grep -E -w "sh|bash|ksh" >/dev/null 2>&1
}

dc-tools::sc::install() {
  # XXX not exactly portable
  if ! command -v shellcheck; then
    brew install shellcheck
  fi
}

dc-tools::sc::check(){
  if ! shellcheck -s bash -a -x "$1"; then
    echo "fail on \"$1\""
    exit 1
  fi
}

dc-tools::sc::run(){
  dc-tools::sc::list | while read -r script; do
    if dc-tools::sc::isShell "$script"; then
      dc-tools::sc::check "$script"
    fi
  done
}
