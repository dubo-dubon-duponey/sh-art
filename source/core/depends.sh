#!/usr/bin/env bash


dc::depends::mac(){
  # First and foremost, depend on brew (through tarmac)
  [ ! "$(command -v brew)" ] && bash -c "$(curl -fsSL https://raw.github.com/dubo-dubon-duponey/tarmac/master/init)"
}

dc::depends::mac::on(){
  # Install through brew
  [ ! "$(brew list "$1" 2>/dev/null)" ] && brew install "$1"
}

