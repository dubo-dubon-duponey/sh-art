#!/usr/bin/env bash

readonly CLI_DESC="git sign-of & gpg verification helper"

# Initialize
dc::commander::initialize
dc::commander::declare::arg 1 ".+" "" "source" "Source file (or directory) in a git tree"
# Start commander
dc::commander::boot
# Requirements
dc::require git
dc::require gpg

dc::git::allCommits(){
  git -C "$1" log --format=%H
}

dc::git::commitContent(){
  git -C "$1" log -1 --format='format:' --name-status "$2"
}

dc::git::commitMessage(){
  git -C "$1" log -1 --format='format:%B' "$2"
}

dc::git::gpgVerify(){
  git -C "$1" verify-commit "$2"
}

dc::git::resignEverything(){
  git -C "$1" filter-branch -f --commit-filter 'git commit-tree -S "$@";' -- --all
}

regex="^Signed-off-by: ([^<]+) <([^<>@]+@[^<>]+)>( \\(github: ([a-zA-Z0-9][a-zA-Z0-9-]+)\\))?$"

for commit in $(dc::git::allCommits "$DC_PARGV_1"); do
  dc::logger::debug "Analyzing $commit"
  if [ ! "$(dc::git::commitContent "$DC_PARGV_1" "$commit")" ]; then
    # no content (ie, Merge commit, etc)
    dc::logger::warning "Ignoring empty merge commit $commit"
    continue
  fi
  if ! dc::git::commitMessage "$DC_PARGV_1" "$commit" | grep -qE "$regex"; then
    badCommits+=( "$commit" )
    dc::logger::error "NOT signed-off appropriately"
  else
    dc::logger::debug "Commit is signed-off appropriately"
  fi
  if ! dc::git::gpgVerify "$DC_PARGV_1" "$commit" 2>/dev/null; then
    # XXX temporarily disabling this
    # badCommits+=( "$commit" )
    dc::logger::error "NOT gpg signed properly ($commit)"
  fi
done

if ! [ ${#badCommits[@]} -eq 0 ]; then
  dc::logger::error "These commits are problematic:"
  for commit in "${badCommits[@]}"; do
    dc::logger::error " - $commit"
  done
  exit "$ERROR_FAILED"
fi
