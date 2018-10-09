#!/usr/bin/env bash

dc-tools::assert::null(){
  assertNull "$@"
}

dc-tools::assert::notnull(){
  assertNotNull "$@"
}

dc-tools::assert::equal(){
  assertEquals "$@"
}

dc-tools::assert::notequal(){
  assertNotEquals "$@"
}

