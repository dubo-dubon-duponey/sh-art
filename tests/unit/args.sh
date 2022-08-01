#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

testArgumentProcessing(){
  local exitcode

  . source/core/args.sh

  exitcode=0

  dc::args::parse "-t" "-u=bar ∞" "--ul" --ul-u_V="Baz baz ∞ bloom" "ignorethis" "foo" "baz=\"baz" "-fake" "--fake-it∞=really ∞" || exitcode=$?

  dc-tools::assert::equal "args parsing" "NO_ERROR" "$(dc::error::lookup $exitcode)"

  dc-tools::assert::equal "argument 2" "x" "${DC_ARG_2+x}"
  dc-tools::assert::equal "argument 2" "foo" "$DC_ARG_2"

  dc-tools::assert::equal "argument 3" "x" "${DC_ARG_3+x}"
  dc-tools::assert::equal "argument 3" 'baz="baz' "$DC_ARG_3"

  dc-tools::assert::equal "argument 4" "x" "${DC_ARG_4+x}"
  dc-tools::assert::equal "argument 4" "-fake" "$DC_ARG_4"

  dc-tools::assert::equal "argument 5" "x" "${DC_ARG_5+x}"
  dc-tools::assert::equal "argument 5" "--fake-it∞=really ∞" "$DC_ARG_5"

  dc-tools::assert::equal "flag t" "x" "${DC_ARG_T+x}"
  dc-tools::assert::equal "flag t" "" "$DC_ARG_T"

  dc-tools::assert::equal "flag u" "x" "${DC_ARG_U+x}"
  dc-tools::assert::equal "flag u" "bar ∞" "$DC_ARG_U"

  dc-tools::assert::equal "flag ul" "x" "${DC_ARG_UL+x}"
  dc-tools::assert::equal "flag ul" "" "$DC_ARG_UL"

  dc-tools::assert::equal "flag ul_u_v" "x" "${DC_ARG_UL_U_V+x}"
  dc-tools::assert::equal "flag ul_u_v" "Baz baz ∞ bloom" "$DC_ARG_UL_U_V"

  exitcode=0
  dc::args::validate t || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} t" "0" "$exitcode"

  exitcode=0
  dc::args::validate u "^bar" || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} u" "0" "$exitcode"

  exitcode=0
  dc::args::validate ul_u_v "^baz" "" insensitive || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} ul_u_v" "0" "$exitcode"

  exitcode=0
  dc::args::validate w "^baz" optional || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} w" "0" "$exitcode"

  exitcode=0
  dc::args::validate ul_u_v "^baz" || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} case sensitiveness failed validation" "$ERROR_ARGUMENT_INVALID" "$exitcode"

  exitcode=0
  dc::args::validate ul_u_v "^Babar" || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} non matching regexp failed validation" "$ERROR_ARGUMENT_INVALID" "$exitcode"

  exitcode=0
  dc::args::validate w || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} non existent flag failed validation" "$ERROR_ARGUMENT_MISSING" "$exitcode"

  exitcode=0
  dc::args::validate 2 || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} 2" "0" "$?"

  exitcode=0
  dc::args::validate 2 "foo$" || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} 2" "0" "$?"

  exitcode=0
  dc::args::validate 2 "^FOO" "" insensitive || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} 2" "0" "$?"

  exitcode=0
  dc::args::validate 10 "foo$" optional || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} 10" "0" "$?"

  exitcode=0
  dc::args::validate 2 "^FOO" || exitcode=$?
  dc-tools::assert::equal "Case sensitiveness failed validation" "$ERROR_ARGUMENT_INVALID" "$exitcode"

  exitcode=0
  dc::args::validate 2 "^Babar" || exitcode=$?
  dc-tools::assert::equal "Non matching regexp failed validation" "$ERROR_ARGUMENT_INVALID" "$exitcode"

  exitcode=0
  dc::args::validate 10 || exitcode=$?
  dc-tools::assert::equal "Non existent arg failed validation" "$ERROR_ARGUMENT_MISSING" "$exitcode"
}
