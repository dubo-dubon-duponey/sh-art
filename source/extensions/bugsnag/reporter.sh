#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

dc::reporter::configure(){
  _DC_INTERNAL_BUGSNAG_KEY="$1"
}

dc::reporter::send(){
  local payload="$1"
  # https://stackoverflow.com/questions/7216358/date-command-on-os-x-doesnt-have-iso-8601-i-option
  local now
  now="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  local headers=(
    "Accept: application/json; version=2"
    "Content-Type: application/json"
    "Bugsnag-Api-Key: $_DC_INTERNAL_BUGSNAG_KEY"
    "Bugsnag-Payload-Version: 5"
    "Bugsnag-Sent-At: $now"
  )
  # XXX this is broken right now
  dc::http::request "https://notify.bugsnag.com/" POST <(printf "%s" "$payload") /dev/stdout "${headers[@]}"
}

dc::reporter::handler(){
  local exit="$1"
  local detail="$2"
  local command="$3"
  local lineno="$4"

  # Walk out if we are not registered
  [ "$_DC_INTERNAL_BUGSNAG_KEY" ] || return 0

  # shellcheck disable=SC2034
  local versions=(
    "\"DC_VERSION\": \"$DC_VERSION\""
    "\"DC_REVISION\": \"$DC_REVISION\""
    "\"DC_BUILD_DATE\": \"$DC_BUILD_DATE\""
    "\"DC_BUILD_PLATFORM\": \"$DC_BUILD_PLATFORM\""
    "\"DC_LIB_VERSION\": \"$DC_LIB_VERSION\""
    "\"DC_LIB_REVISION\": \"$DC_LIB_REVISION\""
    "\"DC_LIB_BUILD_DATE\": \"$DC_LIB_BUILD_DATE\""
    "\"DC_LIB_BUILD_PLATFORM\": \"$DC_LIB_BUILD_PLATFORM\""
    "\"uname\": \"$(uname -a || true)\""
    "\"bash\": \"$(command -v bash || true) $(dc::internal::version::get bash)\""
    "\"grep\": \"$(command -v grep || true) $(dc::internal::version::get grep)\""
    "\"ps\": \"$(command -v ps || true)\""
    "\"[\": \"$(command -v \[ || true)\""
    "\"tput\": \"$(command -v tput || true)\""
    "\"read\": \"$(command -v read || true)\""
    "\"date\": \"$(command -v date || true)\""
    "\"sed\": \"$(command -v sed || true)\""
    "\"printf\": \"$(command -v printf || true)\""
    "\"tr\": \"$(command -v tr || true)\""
    "\"rm\": \"$(command -v rm || true)\""
    "\"mkdir\": \"$(command -v mkdir || true)\""
    "\"mktemp\": \"$(command -v mktemp || true)\""
    "\"curl\": \"$(command -v curl || true) $(dc::internal::version::get curl || true)\""
    "\"jq\": \"$(command -v jq || true) $(dc::internal::version::get jq || true)\""
    "\"openssl\": \"$(command -v openssl || true) $(dc::internal::version::get openssl version || true)\""
    "\"shasum\": \"$(command -v shasum || true) $(dc::internal::version::get shasum || true)\""
    "\"sqlite3\": \"$(command -v sqlite3 || true) $(dc::internal::version::get sqlite3 || true)\""
    "\"uchardet\": \"$(command -v uchardet || true) $(dc::internal::version::get uchardet || true)\""
    "\"iconv\": \"$(command -v uchardet || true) $(dc::internal::version::get iconv || true)\""
    "\"make\": \"$(command -v make || true) $(dc::internal::version::get make || true)\""
    "\"git\": \"$(command -v git || true) $(dc::internal::version::get git || true)\""
    "\"gcc\": \"$(command -v gcc || true) $(dc::internal::version::get gcc || true)\""
  )

  # XXX env doesn't work yet
  local nv=()
  while read -r line; do
    nv+=("$line")
  done < <(env)
  # XXX --argjson env "$(printf "[\"%s\"]" "$(dc::string::join nv "\", \"")")" \

  local payload
  payload="$(printf "{%s}" "$(dc::string::join versions ",")" | jq  --arg appKey "$_DC_INTERNAL_BUGSNAG_KEY" \
        --arg appName "Bugsnag sh-art" \
        --arg appVersion "$DC_LIB_VERSION" \
        --arg appUrl "https://github.com/dubo-dubon-duponey/sh-art" \
        --arg error "$(dc::error::lookup "$exit") - $exit" \
        --arg file "${BASH_SOURCE[0]}" \
        --arg line "$lineno" \
        --arg command "$command" \
        --arg message "$detail" \
        --arg path "$PATH" \
        --arg appId "org.dubodubonduponey.sh-art" '{
      "apiKey": $appKey,
      "payloadVersion": "5",
      "notifier": {
        "name": $appName,
        "version": $appVersion,
        "url": $appUrl
      },
      "events": [
        {
          "exceptions": [
            {
              "errorClass": $error,
              "message": $message,
              "stacktrace": [
                {
                  "file": $file,
                  "lineNumber": $line,
                  "method": $command
                }
              ]
            }
          ],
          "app": {
            "id": $appId,
            "version": $appVersion,
            "releaseStage": "staging",
            "type": "bash"
          },
          "device": {
          },
          "session": {},
          "metaData": {
            "env": "$env",
            "path": $path,
            "os": .
          }
        }
      ]
    }')"

  dc::reporter::send "$payload"
}

dc::reporter::boot(){
  # Add the key
  dc::reporter::configure "$1"
  # Attach the error handler
  dc::trap::register dc::reporter::handler
}

