#!/usr/bin/env bash
##########################################################################
# JWT
# ------
# JWT helpers
##########################################################################

DC_JWT_TOKEN=
DC_JWT_HEADER=
DC_JWT_PAYLOAD=
DC_JWT_ACCESS=

dc::jwt::read(){
  DC_JWT_TOKEN="$1"
  local decoded=($(echo $1 | tr "." " "))
  #local sig

  # XXX WTFFFFF base64
  DC_JWT_HEADER=$(echo ${decoded[0]}== | base64 -D 2>/dev/null)
  if [[ $? != 0 ]]; then
    DC_JWT_HEADER=$(echo ${decoded[0]} | base64 -D)
  fi
  DC_JWT_PAYLOAD=$(echo ${decoded[1]}== | base64 -D 2>/dev/null)
  if [[ $? != 0 ]]; then
    DC_JWT_PAYLOAD=$(echo ${decoded[1]} | base64 -D)
  fi
  #sig=$(echo ${decoded[2]}== | base64 -D 2>/dev/null)
  #if [[ $? != 0 ]]; then
  #  sig=$(echo ${decoded[2]} | base64 -D)
  #fi

  if [ ! "$_DC_HTTP_REDACT" ]; then
    dc::logger::info "[JWT] header: $(echo $DC_JWT_HEADER | jq '.')"
    dc::logger::info "[JWT] payload: $(echo $DC_JWT_PAYLOAD | jq '.')"
    # TODO implement signature verification? not super useful...
    # dc::logger::debug "[JWT] sig: $(echo $sig)"
  fi

  # Grab the access response
  DC_JWT_ACCESS=$(echo $DC_JWT_PAYLOAD | jq '.access')
}
