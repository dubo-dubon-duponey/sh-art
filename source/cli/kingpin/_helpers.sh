#!/usr/bin/env bash

helpers::profile_link(){
  local posh="$1"
  if ! grep -q "$posh" "$HOME/.profile"; then
    printf "%s\\n" "# shellcheck source=$HOME/$posh" >> "$HOME/.profile"
    printf "%s\\n" ". \"\$HOME/$posh\"" >> "$HOME/.profile"
  fi
}
