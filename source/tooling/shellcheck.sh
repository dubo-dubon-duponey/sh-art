#!/usr/bin/env bash

dc-tools::sc::list(){
# XXX neither approach are satisfying...
#  git ls-tree -r HEAD | grep -E '^1007|.*\..*sh$' | awk '{print $4}' | grep -v tests
  find ./ -type f \( -perm +111 -o -iname "*.sh" \) -not -path ".//.git*" -not -path ".//bin*" -not -path ".//xxx*"
}

dc-tools::sc::isShell() {
	head -n1 "$1" | grep -E -w "sh|bash|ksh" >/dev/null 2>&1
}

dc-tools::sc::install() {
  if ! command -v shellcheck > /dev/null; then
    # XXX not exactly portable
    brew install shellcheck
  fi
}

dc-tools::sc::check(){
  # Ignore process substitution, "local", and function naming restrictions
  if ! shellcheck -s bash -a -x "$1"; then
    printf "%s\\n" "failing on \"$1\""
    export SHELLCHECK_FAIL=true
  fi
}

dc-tools::sc::run(){
  dc-tools::sc::list | while read -r script; do
    local bn
    bn=$(basename "$script")
    if [ "${bn:0:1}" == "." ]; then
      continue
    fi

    if dc-tools::sc::isShell "$script"; then
      dc-tools::sc::check "$script"
    fi
  done
  if [ "$SHELLCHECK_FAIL" ]; then
    exit 1
  fi
}
