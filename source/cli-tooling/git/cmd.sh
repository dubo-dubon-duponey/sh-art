#!/usr/bin/env bash

readonly CLI_DESC="git sign-of verification helper"

# Initialize
dc::commander::initialize
dc::commander::declare::arg 1 ".+" "" "source" "Source file (or directory) in a git tree"
# Start commander
dc::commander::boot
# Requirements
dc::require git

allcommits="$(git log --format=%H -C "$1")"
regex="^Signed-off-by: ([^<]+) <([^<>@]+@[^<>]+)>( \\(github: ([a-zA-Z0-9][a-zA-Z0-9-]+)\\))?$"

for commit in ${allcommits}; do
  dc::logger::debug "Analyzing $commit"
  if [ -z "$(git log -1 --format='format:' --name-status "$commit")" ]; then
    # no content (ie, Merge commit, etc)
    dc::logger::warning "Ignoring commit $commit"
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
