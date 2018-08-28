#!/usr/bin/env bash

helpers::profile_link(){
  local posh=$1
  if [ -z "$(cat ~/.profile | grep $posh)" ]; then
    echo ". ~/$posh" >> ~/.profile
    source ~/.profile
  fi
}
