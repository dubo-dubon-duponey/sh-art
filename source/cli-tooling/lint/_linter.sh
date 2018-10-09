#!/usr/bin/env bash

dc-tools::sc::install() {
  if ! command -v shellcheck > /dev/null; then
    dc::logger::warning "[linter] shellcheck is not installed. Press enter to install now."
    dc::prompt::confirm
    # XXX not exactly portable
    brew install shellcheck
  fi
}

dc-tools::sc::filecheck(){
  if ! head -n1 "$1" | grep -q -E -w "sh|bash|ksh"; then
    dc::logger::warning "[linter] ignoring $1 (no recognized shebang)"
    return
  fi
  dc::logger::info "[linter] shellchecking \"$1\""
  if ! shellcheck -a -x "$1"; then # -s bash
    dc::logger::error "[linter] shellcheck failed on: \"$1\""
    export DC_SHELLCHECK_FAIL=true
  fi
}

dc-tools::sc::dircheck(){
# XXX neither approach are satisfying...
#  git ls-tree -r HEAD | grep -E '^1007|.*\..*sh$' | awk '{print $4}' | grep -v tests
  while read -r script; do
    if ! dc-tools::sc::filecheck "$script"; then
      # XXX subshell modification is not going to bubble up...
      export DC_SHELLCHECK_FAIL=true
    fi
  done < <(find "$1" -type f \( -perm +111 -o -iname "*.sh" \) -not -iname ".*" -not -path "*/.git/*" -not -path "*/xxx*")
}
