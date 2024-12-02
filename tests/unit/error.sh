#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

testInternalErrorRegistration() {
  local res
  local exitcode

  exitcode=0
  dc::internal::error::register SOMETHING || exitcode="$?"
  dc-tools::assert::equal "register return" "0" "$exitcode"

  dc-tools::assert::notnull "Var should not be null" "${ERROR_SOMETHING:-}"
  dc-tools::assert::notnull "It should appear in the ENV" "$(env | grep ERROR_SOMETHING)"

  res="$(dc::error::lookup "${ERROR_SOMETHING:-}")" || exitcode="$?"
  dc-tools::assert::equal "lookup return" "0" "$exitcode"
  dc-tools::assert::equal "ERROR_SOMETHING HAS A CODE" "SOMETHING" "$res"
}

testErrorDetailGetAndSet() {
  local res
  local exitcode

  exitcode=0
  dc::error::detail::set "foobar ∞" || exitcode="$?"
  dc-tools::assert::equal "set return" "0" "$exitcode"

  res="$(dc::error::detail::get)" || exitcode="$?"
  dc-tools::assert::equal "get return" "0" "$exitcode"
  dc-tools::assert::equal "get what was set" "foobar ∞" "$res"
}

testErrorRegistration() {
  local res
  local exitcode

  exitcode=0
  dc::error::register "-INVALID" || exitcode="$?"
  dc-tools::assert::equal "register return" "ARGUMENT_INVALID" "$(dc::error::lookup "$exitcode")"

  exitcode=0
  dc::error::register SOMETHING_ELSE || exitcode="$?"
  dc-tools::assert::equal "register return" "0" "$exitcode"

  dc-tools::assert::notnull "Var should not be null" "${ERROR_SOMETHING_ELSE:-}"
  dc-tools::assert::notnull "It should appear in the ENV" "$(env | grep ERROR_SOMETHING_ELSE)"

  res="$(dc::error::lookup "${ERROR_SOMETHING_ELSE:-}")" || exitcode="$?"
  dc-tools::assert::equal "lookup return" "0" "$exitcode"
  dc-tools::assert::equal "ERROR_SOMETHING HAS A CODE" "SOMETHING_ELSE" "$res"
}

testErrorLookup() {
  local exitcode

  dc-tools::assert::equal "register return" "SYSTEM_SIGALRM" "$(dc::error::lookup 142)"

  exitcode=0
  dc::error::lookup "not an integer" || exitcode="$?"
  dc-tools::assert::equal "lookup failure" "ARGUMENT_INVALID" "$(dc::error::lookup "$exitcode")"

  exitcode=0
  dc::error::lookup "-250" || exitcode="$?"
  dc-tools::assert::equal "lookup failure" "ARGUMENT_INVALID" "$(dc::error::lookup "$exitcode")"

  exitcode=0
  dc::error::lookup "2500" || exitcode="$?"
  dc-tools::assert::equal "lookup failure" "ARGUMENT_INVALID" "$(dc::error::lookup "$exitcode")"

  exitcode=0
  dc::error::lookup "1.1" || exitcode="$?"
  dc-tools::assert::equal "lookup failure" "ARGUMENT_INVALID" "$(dc::error::lookup "$exitcode")"

}
