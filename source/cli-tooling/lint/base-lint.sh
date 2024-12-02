#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

dc::error::register LINT_FAIL

dc-tooling::sc::filecheck(){
  dc::logger::info "[linter] checking \"$1\""
  # Hadolint
  if [[ "$1" = *"Dockerfile"* ]]; then
    if ! hadolint "$1"; then
      dc::error::throw LINT_FAIL || return
    fi
    return
  fi
  # Shellcheck
  head -n1 "$1" | dc::wrapped::grep -q -w "sh|bash|ksh" \
    || {
      dc::logger::warning "[linter] shellcheck ignoring $1 (no recognized shebang)"
      return
    }

  shellcheck -a -x "$1" || dc::error::throw LINT_FAIL || return
}

dc-tooling::sc::dircheck(){
  local error=
# XXX neither approach are satisfying...
#  git ls-tree -r HEAD | dc::wrapped::grep -E '^1007|.*\..*sh$' | awk '{print $4}' | dc::wrapped::grep -v tests
  while read -r script; do
    dc-tooling::sc::filecheck "$script" || error=true
  done < <(
    # XXX DAMN YOU, GNU
    if ! find "$1" -type f \( -perm /111 -o -iname "*.sh" \) -not -iname ".*" -not -path "*/.git/*" -not -path "*/xxx*" 2>/dev/null; then
      find "$1" -type f \( -perm +111 -o -iname "*.sh" \) -not -iname ".*" -not -path "*/.git/*" -not -path "*/xxx*" 2>/dev/null
    fi
  )
  [ ! "$error" ] || dc::error::throw LINT_FAIL || return
}
