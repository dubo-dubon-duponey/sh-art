#!/usr/bin/env bash

dc-tools::sc::filecheck(){
  dc::logger::info "[linter] checking \"$1\""
  # Hadolint
  if [[ "$1" = *"Dockerfile"* ]]; then
    if ! hadolint "$1"; then
      dc::logger::error "[linter] hadolint failed on: \"$1\""
      export DC_SHELLCHECK_FAIL=true
    fi
    return
  fi
  # Shellcheck
  if ! head -n1 "$1" | grep -q -E -w "sh|bash|ksh"; then
    dc::logger::warning "[linter] shellcheck ignoring $1 (no recognized shebang)"
    return
  fi
  if ! shellcheck -a -x "$1"; then # -s bash
    dc::logger::error "[linter] shellcheck failed on: \"$1\""
    export DC_SHELLCHECK_FAIL=true
  fi
}

dc-tools::sc::dircheck(){
# XXX neither approach are satisfying...
#  git ls-tree -r HEAD | grep -E '^1007|.*\..*sh$' | awk '{print $4}' | grep -v tests
  while read -r script; do
    export FOO=true
    if ! dc-tools::sc::filecheck "$script"; then
      export DC_SHELLCHECK_FAIL=true
    fi
  done < <(
    # XXX DAMN YOU, GNU
    if ! find "$1" -type f \( -perm /111 -o -iname "*.sh" \) -not -iname ".*" -not -path "*/.git/*" -not -path "*/xxx*" 2>/dev/null; then
      find "$1" -type f \( -perm +111 -o -iname "*.sh" \) -not -iname ".*" -not -path "*/.git/*" -not -path "*/xxx*" 2>/dev/null
    fi
  )
}
