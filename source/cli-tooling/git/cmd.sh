#!/usr/bin/env bash

readonly CLI_DESC="git sign-of verification helper"

# Initialize
dc::commander::initialize
dc::commander::declare::arg 1 ".+" "" "source" "Source file (or directory) in a git tree"
# Start commander
dc::commander::boot
# Requirements
dc::require git

allcommits="$(git -C "$1" log --format=%H)"
regex="^Signed-off-by: ([^<]+) <([^<>@]+@[^<>]+)>( \\(github: ([a-zA-Z0-9][a-zA-Z0-9-]+)\\))?$"

for commit in ${allcommits}; do
  dc::logger::debug "Analyzing $commit"
  if [ -z "$(git -C "$1" log -1 --format='format:' --name-status "$commit")" ]; then
    # no content (ie, Merge commit, etc)
    dc::logger::warning "Ignoring commit $commit"
    continue
  fi
  if ! git -C "$1" log -1 --format='format:%B' "$commit" | grep -qE "$regex"; then
    badCommits+=( "$commit" )
    dc::logger::error "NOT signed-off appropriately"
  else
    dc::logger::debug "Commit is signed-off appropriately"
  fi
  if ! git -C "$1" verify-commit "$commit" 2>/dev/null; then
    badCommits+=( "$commit" )
    dc::logger::error "NOT gpg signed properly"
  fi
done

if ! [ ${#badCommits[@]} -eq 0 ]; then
  dc::logger::error "These commits are problematic:"
  for commit in "${badCommits[@]}"; do
    dc::logger::error " - $commit"
  done
  dc::logger::error 'Please amend.'
  exit "$ERROR_FAILED"
fi


# Resign everything with gpg
# git filter-branch --commit-filter 'git commit-tree -S "$@";' -- --all
