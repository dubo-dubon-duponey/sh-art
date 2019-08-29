#!/usr/bin/env bash

true
# shellcheck disable=SC2034
readonly CLI_DESC="git sign-of & gpg verification helper"

# Initialize
dc::commander::initialize
dc::commander::declare::arg 1 ".+" "source" "Source file (or directory) in a git tree"
# Start commander
dc::commander::boot

# Requirements
dc::require git || exit
dc::require gpg || exit

dc-tooling::git::allCommits(){
  git -C "$1" log --format=%H
}

dc-tooling::git::commitContent(){
  git -C "$1" log -1 --format='format:' --name-status "$2"
}

dc-tooling::git::commitMessage(){
  git -C "$1" log -1 --format='format:%B' "$2"
}

dc-tooling::git::gpgVerify(){
  git -C "$1" verify-commit "$2"
}

dc-tooling::git::resignEverything(){
  git -C "$1" filter-branch -f --commit-filter 'git commit-tree -S "$@";' -- --all
}

# Import committed keys
for i in ./keys/*.pub; do
  gpg --import "$i"
done

regex="^Signed-off-by: ([^<]+) <([^<>@]+@[^<>]+)>( \\(github: ([a-zA-Z0-9][a-zA-Z0-9-]+)\\))?$"

for commit in $(dc-tooling::git::allCommits "$DC_PARGV_1"); do
  dc::logger::debug "Analyzing $commit"
  if [ ! "$(dc-tooling::git::commitContent "$DC_PARGV_1" "$commit")" ]; then
    # no content (ie, Merge commit, etc)
    dc::logger::warning "Ignoring empty merge commit $commit"
    continue
  fi
  if ! dc-tooling::git::commitMessage "$DC_PARGV_1" "$commit" | dc::internal::grep -q "$regex"; then
    badCommits+=( "$commit" )
    dc::logger::error "$commit is NOT signed-off appropriately"
    dc::logger::error "Content was: $(dc-tooling::git::commitContent "$DC_PARGV_1" "$commit")"
    dc::logger::error "Message was: $(dc-tooling::git::commitMessage "$DC_PARGV_1" "$commit")"
    continue
  fi

  dc::logger::info "Commit $commit is signed-off appropriately"

  if ! dc-tooling::git::gpgVerify "$DC_PARGV_1" "$commit" 2>/dev/null; then
    # XXX temporarily disabling this
    badCommits+=( "$commit" )
    dc::logger::error "NOT gpg signed properly ($commit)"
  fi
done

if [ ${#badCommits[@]} != 0 ]; then
  dc::logger::error "These commits are problematic:"
  for commit in "${badCommits[@]}"; do
    dc::logger::error " - $commit"
  done
  exit "$ERROR_FAILED"
fi
