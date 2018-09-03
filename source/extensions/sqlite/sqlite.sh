#!/usr/bin/env bash

_DC_EXT_SQLITE_DB=

dc-ext::sqlite::init(){
  mkdir -p $(dirname "$1")
  _DC_EXT_SQLITE_DB="$1"
}

#_dc-ext::sqlite::cmd(){
#  result=$(echo "$1" | sqlite3 "$_DC_EXT_SQLITE_DB")
#}

dc-ext::sqlite::ensure(){
# echo "create table if not exists testable (method TEXT, url TEXT, content BLOB, PRIMARY KEY(method, url))" | sqlite3 test.db
  local table=$1
  local description="$2"
  result=$(echo "create table if not exists $table ($description)" | sqlite3 "$_DC_EXT_SQLITE_DB")
}

dc-ext::sqlite::select(){
  local table=$1
  result=$(echo "select $2 from $table where $3" | sqlite3 "$_DC_EXT_SQLITE_DB")
}

dc-ext::sqlite::insert(){
  local table=$1
  local fields="$2"
  local values="$3"
  shift
  shift
  echo "INSERT INTO $table ($fields) VALUES ($values)" | sqlite3 "$_DC_EXT_SQLITE_DB"
}

dc-ext::sqlite::delete(){
  echo "DELETE from $table where $condition" | sqlite3 "$_DC_EXT_SQLITE_DB"
}
