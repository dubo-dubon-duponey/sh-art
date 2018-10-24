#!/usr/bin/env bash

# XXX this is a POC implementation
# Input is NOT sanitized, and very likely to be prone to injections if left unchecked
# Do NOT rely on this for anything sensitive

_DC_EXT_SQLITE_DB=

dc-ext::sqlite::init(){
  dc::require sqlite3
  mkdir -p "$(dirname "$1")"
  _DC_EXT_SQLITE_DB="$1"
}

#_dc-ext::sqlite::cmd(){
#  result=$(echo "$1" | sqlite3 "$_DC_EXT_SQLITE_DB")
#}

dc-ext::sqlite::ensure(){
# echo "create table if not exists testable (method TEXT, url TEXT, content BLOB, PRIMARY KEY(method, url))" | sqlite3 test.db
  local table="$1"
  local description="$2"
  printf "%s" "create table if not exists $table ($description);" | sqlite3 "$_DC_EXT_SQLITE_DB"
}

dc-ext::sqlite::select(){
  local table="$1"
  printf "%s" "select $2 from $table where $3;" | sqlite3 "$_DC_EXT_SQLITE_DB"
}

dc-ext::sqlite::insert(){
  local table="$1"
  local fields="$2"
  local values="$3"
  shift
  shift
  printf "%s" "INSERT INTO $table ($fields) VALUES ($values);" | sqlite3 "$_DC_EXT_SQLITE_DB"
}

dc-ext::sqlite::delete(){
  local table="$1"
  local condition="$2"
  printf "%s" "DELETE from $table where $condition;" | sqlite3 "$_DC_EXT_SQLITE_DB"
}
