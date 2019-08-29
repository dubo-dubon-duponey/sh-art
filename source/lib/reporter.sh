#!/usr/bin/env bash

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
  dc::http::request "https://notify.bugsnag.com/" POST <(printf "%s" "$payload") "${headers[@]}"
}

dc::reporter::handler(){
  # Walk out if we are not registered
  [ "$_DC_INTERNAL_BUGSNAG_KEY" ] || return 0

  local exit="$1"
  local detail="$2"
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
    "\"uname\": \"$(uname -a)\""
    "\"bash\": \"$(command -v bash) $(dc::require::version bash --version)\""
    "\"curl\": \"$(command -v curl) $(dc::require::version curl --version)\""
    "\"grep\": \"$(command -v grep) $(dc::require::version grep --version)\""
    "\"jq\": \"$(command -v jq) $(dc::require::version jq --version)\""
    "\"openssl\": \"$(command -v openssl) $(dc::require::version openssl version)\""
    "\"shasum\": \"$(command -v shasum) $(dc::require::version shasum --version)\""
    "\"sqlite3\": \"$(command -v sqlite3) $(dc::require::version sqlite3 --version)\""
    "\"uchardet\": \"$(command -v uchardet) $(dc::require::version uchardet --version)\""
    "\"make\": \"$(command -v make) $(dc::require::version make --version)\""
    "\"git\": \"$(command -v git) $(dc::require::version git --version)\""
    "\"gcc\": \"$(command -v gcc) $(dc::require::version gcc --version)\""
    "\"ps\": \"$(command -v ps)\""
    "\"[\": \"$(command -v \[)\""
    "\"tput\": \"$(command -v tput)\""
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
        --arg line 1 \
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
                  "method": ""
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

