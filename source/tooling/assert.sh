#!/usr/bin/env bash

dc-tools::assert::null(){
  local context="$2"
  if [ "$context" ]; then
    context=" (context: $context)"
  fi
  if [ "$1" ]; then
    echo "[$(date)] [ERROR] Expecting '$1' to be null$context"
    exit 1
  fi
}

dc-tools::assert::notnull(){
  local context="$2"
  if [ "$context" ]; then
    context=" (context: $context)"
  fi
  if [ ! "$1" ]; then
    echo "[$(date)] [ERROR] Expecting '$1' to not be null$context"
    exit 1
  fi
}

dc-tools::assert::equal(){
  local context="$3"
  if [ "$context" ]; then
    context=" (context: $context)"
  fi
  if [ "$1" != "$2" ]; then
    echo "[$(date)] [ERROR] Expecting '$1' to be equal to '$2'$context"
    exit 1
  fi
}

dc-tools::assert::notequal(){
  local context="$3"
  if [ "$context" ]; then
    context=" (context: $context)"
  fi
  if [ "$1" == "$2" ]; then
    echo "[$(date)] [ERROR] Expecting '$1' to not be '$2'$context"
    exit 1
  fi
}
