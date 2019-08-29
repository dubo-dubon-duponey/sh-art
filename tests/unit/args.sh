#!/usr/bin/env bash

testArgumentProcessing(){
  . source/core/args.sh
  dc::internal::parse_args "-t" "-u=bar ∞" "--ul" --ul-u_V="Baz baz ∞ bloom" "ignorethis" "foo" "baz=\"baz" "-fake" "--fake-it∞=really ∞"

  dc-tools::assert::equal "argument 2" "true" "$DC_PARGE_2"
  dc-tools::assert::equal "argument 2" "foo" "$DC_PARGV_2"
  dc-tools::assert::equal "argument 3" "true" "$DC_PARGE_3"
  dc-tools::assert::equal "argument 3" 'baz="baz' "$DC_PARGV_3"
  dc-tools::assert::equal "argument 4" "true" "$DC_PARGE_4"
  dc-tools::assert::equal "argument 4" "-fake" "$DC_PARGV_4"
  dc-tools::assert::equal "argument 5" "true" "$DC_PARGE_5"
  dc-tools::assert::equal "argument 5" "--fake-it∞=really ∞" "$DC_PARGV_5"
  dc-tools::assert::equal "flag t" "true" "$DC_ARGE_T"
  dc-tools::assert::equal "flag t" "" "$DC_ARGV_T"
  dc-tools::assert::equal "flag u" "true" "$DC_ARGE_U"
  dc-tools::assert::equal "flag u" "bar ∞" "$DC_ARGV_U"
  dc-tools::assert::equal "flag ul" "true" "$DC_ARGE_UL"
  dc-tools::assert::equal "flag ul" "" "$DC_ARGV_UL"
  dc-tools::assert::equal "flag ul_u_v" "true" "$DC_ARGE_UL_U_V"
  dc-tools::assert::equal "flag ul_u_v" "Baz baz ∞ bloom" "$DC_ARGV_UL_U_V"

  dc::args::flag::validate t
  dc-tools::assert::equal "${FUNCNAME[0]} t" "0" "$?"
  dc::args::flag::validate u "^bar"
  dc-tools::assert::equal "${FUNCNAME[0]} u" "0" "$?"
  dc::args::flag::validate ul_u_v "^baz" "" insensitive
  dc-tools::assert::equal "${FUNCNAME[0]} ul_u_v" "0" "$?"
  dc::args::flag::validate w "^baz" optional
  dc-tools::assert::equal "${FUNCNAME[0]} w" "0" "$?"

  dc::args::flag::validate ul_u_v "^baz"
  dc-tools::assert::equal "${FUNCNAME[0]} case sensitiveness failed validation" "$ERROR_ARGUMENT_INVALID" "$?"

  dc::args::flag::validate ul_u_v "^Babar"
  dc-tools::assert::equal "${FUNCNAME[0]} non matching regexp failed validation" "$ERROR_ARGUMENT_INVALID" "$?"

  dc::args::flag::validate w
  dc-tools::assert::equal "${FUNCNAME[0]} non existent flag failed validation" "$ERROR_ARGUMENT_MISSING" "$?"

  dc::args::arg::validate 2
  dc-tools::assert::equal "${FUNCNAME[0]} 2" "0" "$?"
  dc::args::arg::validate 2 "foo$"
  dc-tools::assert::equal "${FUNCNAME[0]} 2" "0" "$?"
  dc::args::arg::validate 2 "^FOO" "" insensitive
  dc-tools::assert::equal "${FUNCNAME[0]} 2" "0" "$?"
  dc::args::arg::validate 10 "foo$" optional
  dc-tools::assert::equal "${FUNCNAME[0]} 10" "0" "$?"

  dc::args::arg::validate 2 "^FOO"
  dc-tools::assert::equal "Case sensitiveness failed validation" "$ERROR_ARGUMENT_INVALID" "$?"

  dc::args::arg::validate 2 "^Babar"
  dc-tools::assert::equal "Non matching regexp failed validation" "$ERROR_ARGUMENT_INVALID" "$?"

  dc::args::arg::validate 10
  dc-tools::assert::equal "Non existent arg failed validation" "$ERROR_ARGUMENT_MISSING" "$?"

}
