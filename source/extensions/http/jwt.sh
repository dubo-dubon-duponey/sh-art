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

dc-ext::jwt::read(){
  dc::require jq

  export DC_JWT_TOKEN="$1"

  local decoded
  read -r -a decoded< <(printf "%s" "$1" | tr "." " ")
  #local sig

  # XXX WTFFFFF base64
  if ! DC_JWT_HEADER="$(printf "%s" "${decoded[0]}==" | dc::portable::base64d 2>/dev/null)"; then
    DC_JWT_HEADER="$(printf "%s" "${decoded[0]}" | dc::portable::base64d)"
  fi
  if ! DC_JWT_PAYLOAD="$(printf "%s" "${decoded[1]}==" | dc::portable::base64d 2>/dev/null)"; then
    DC_JWT_PAYLOAD="$(printf "%s" "${decoded[1]}" | dc::portable::base64d)"
  fi
  #sig=$(printf "%s" ${decoded[2]}== | dc::portable::base64d 2>/dev/null)
  #if [[ $? != 0 ]]; then
  #  sig=$(printf "%s" ${decoded[2]} | dc::portable::base64d)
  #fi

  if [ ! "$_DC_HTTP_REDACT" ]; then
    dc::logger::debug "[dc-jwt] decoded header: $(printf "%s" "$DC_JWT_HEADER" | jq '.')"
    dc::logger::debug "[dc-jwt] decoded payload: $(printf "%s" "$DC_JWT_PAYLOAD" | jq '.')"
    # TODO implement signature verification? not super useful...
    # dc::logger::debug "[JWT] sig: $(printf "%s" $sig)"
  fi

  # Grab the access response
  export DC_JWT_ACCESS
  DC_JWT_ACCESS="$(printf "%s" "$DC_JWT_PAYLOAD" | jq '.access')"
  dc::logger::debug "[dc-jwt] access for: $DC_JWT_ACCESS"
}
