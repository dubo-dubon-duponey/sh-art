#!/usr/bin/env bash

readonly CLI_VERSION="0.0.1"
readonly CLI_LICENSE="MIT License"
readonly CLI_DESC="git helpers (part of the dc-tooling suite)"
readonly CLI_USAGE="[-s] file-or-directory"

dc::commander::init
dc::require::git

allcommits="$(git log --format=%H -C "$1")"
regex="^Signed-off-by: ([^<]+) <([^<>@]+@[^<>]+)>( \\(github: ([a-zA-Z0-9][a-zA-Z0-9-]+)\\))?$"

for commit in ${allcommits}; do
  dc::logger::debug "Analyzing $commit"
  if [ -z "$(git log -1 --format='format:' --name-status "$commit")" ]; then
    # no content (ie, Merge commit, etc)
    dc::logger::warn "Ignoring commit"
    continue
  fi
  if ! git log -1 --format='format:%B' "$commit" | grep -qE "$regex"; then
    badCommits+=( "$commit" )
    dc::logger::error "NOT signed appropriately"
  else
    dc::logger::debug "Commit is signed appropriately"
  fi
done

if ! [ ${#badCommits[@]} -eq 0 ]; then
  dc::logger::error "These commits are not signed properly:"
  for commit in "${badCommits[@]}"; do
    dc::logger::error " - $commit"
  done
  dc::logger::error 'Please amend each commit to sign them.'
  exit "$ERROR_FAILED"
fi
