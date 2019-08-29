#!/usr/bin/env bash

true
# shellcheck disable=SC2034
readonly CLI_DESC="git / gpg configuration helper"

# Initialize
dc::commander::initialize
dc::commander::declare::flag email "$DC_TYPE_EMAIL" "Email for the gpg signing key you intend on using"
dc::commander::declare::arg 1 "(save|configure)" "command" "save or configure"
# Start commander
dc::commander::boot

# Requirements
dc::require git || exit
dc::require gpg || exit

dc::fs::isdir "./keys" writable create || exit

gpg::newKey(){
  gpg --default-new-key-algo rsa4096 --gen-key
}

gpg::savePubKey(){
  local mail="$1"
  local destination="$2"
  local id

  id="$(gpg --list-keys "$mail" | grep "^      ")" || {
    dc::logger::error "No key found for $mail"
    exit "$DC_ERROR_FAILED"
  }

  gpg --output "$destination/$mail.pub" --armor --export "$id" || return
  git add "./keys/$DC_ARGV_EMAIL.pub" || return
}

git::setConfig(){
  local name="$1"
  local email="$2"
  local gpg="$3"
  if [ "$name" ]; then
    git config --local --unset user.name
    git config --local --add user.name "$name" || return
  fi
  if [ "$email" ]; then
    git config --local --unset user.email
    git config --local --add user.email "$email" || return
  fi
  if [ "$gpg" ]; then
    git config --local --unset user.signingkey
    git config --local --add user.signingkey "$gpg" || return
  fi
}

case "$DC_PARGV_1" in
  # XXX problematic currently - because no-tty
  "new")
    gpg::newKey
  ;;

  "save")
    gpg::savePubKey "$DC_ARGV_EMAIL" "./keys" || exit
  ;;

  "configure")
    id="$(gpg --list-keys "$DC_ARGV_EMAIL" | grep "^      ")" || {
      dc::logger::error "No key found for $DC_ARGV_EMAIL"
      exit "$DC_ERROR_FAILED"
    }
    id="${id##* }"

    dc::output::h1 "Current local git configuration"
    # dc::output::text "Your name: $(git config --local --get user.name)"
    dc::output::text "Your email: $(git config --local --get user.email)"
    dc::output::break
    dc::output::text "Your signing key: $(git config --local --get user.signingkey)"
    dc::output::break

    dc::output::h1 "Proposed local new git configuration"
    # dc::output::text "Your name: $(git config --local --get user.name)"
    dc::output::text "Your email: $DC_ARGV_EMAIL"
    dc::output::break
    dc::output::text "Your signing key: $id"
    dc::output::break
    dc::output::break
    dc::prompt::confirm "Please confirm now by pressing enter"

    git::setConfig "" "$DC_ARGV_EMAIL" "$id"
  ;;
esac


