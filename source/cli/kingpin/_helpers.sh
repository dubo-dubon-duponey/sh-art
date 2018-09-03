#!/usr/bin/env bash

helpers::profile_link(){
  local posh="$1"
  if ! grep -q "$posh" "$HOME/.profile"; then
    echo "# shellcheck source=$HOME/$posh" >> "$HOME/.profile"
    echo ". \"\$HOME/$posh\"" >> "$HOME/.profile"
  fi
}
