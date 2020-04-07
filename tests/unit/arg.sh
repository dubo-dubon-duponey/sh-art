#!/usr/bin/env bash

testArgumentCheckHalfBogusConditions() {
  set +eu
  local exitcode
  local argument
  local regexp

  regexp=""

  argument="whatever"
  exitcode=0
  dc::argument::check argument "$regexp" || exitcode="$?"
  dc-tools::assert::equal "argument: argument (=$argument) - regexp: $regexp" "NO_ERROR" "$(dc::error::lookup $exitcode)"

  argument=""
  exitcode=0
  dc::argument::check argument "$regexp" || exitcode="$?"
  dc-tools::assert::equal "argument: argument (=$argument) - regexp: $regexp" "NO_ERROR" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::argument::check nonexistentargument "$regexp" || exitcode="$?"
  dc-tools::assert::equal "argument: nonexistentargument - regexp: $regexp" "NO_ERROR" "$(dc::error::lookup $exitcode)"

  regexp="whateverregexp"

  argument=""
  exitcode=0
  dc::argument::check argument "$regexp" || exitcode="$?"
  dc-tools::assert::equal "argument: argument (=$argument) - regexp: $regexp" "ARGUMENT_INVALID" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::argument::check nonexistentargument "$regexp" || exitcode="$?"
  dc-tools::assert::equal "argument: nonexistentargument - regexp: $regexp" "ARGUMENT_INVALID" "$(dc::error::lookup $exitcode)"
}

testArgumentCheckTypesNumeric() {
  local exitcode
  local argument

  # Float and ints
  argument=123

  exitcode=0
  dc::argument::check argument "$DC_TYPE_FLOAT" || exitcode="$?"
  dc-tools::assert::equal "arg check $argument float" "NO_ERROR" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::argument::check argument "$DC_TYPE_INTEGER" || exitcode="$?"
  dc-tools::assert::equal "arg check $argument integer" "NO_ERROR" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::argument::check argument "$DC_TYPE_UNSIGNED" || exitcode="$?"
  dc-tools::assert::equal "arg check $argument unsigned" "NO_ERROR" "$(dc::error::lookup $exitcode)"

  argument="-123"

  exitcode=0
  dc::argument::check argument "$DC_TYPE_FLOAT" || exitcode="$?"
  dc-tools::assert::equal "arg check $argument float" "NO_ERROR" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::argument::check argument "$DC_TYPE_INTEGER" || exitcode="$?"
  dc-tools::assert::equal "arg check $argument integer" "NO_ERROR" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::argument::check argument "$DC_TYPE_UNSIGNED" || exitcode="$?"
  dc-tools::assert::equal "arg check $argument unsigned" "ARGUMENT_INVALID" "$(dc::error::lookup $exitcode)"
  exitcode=0

  argument="-123.123"

  exitcode=0
  dc::argument::check argument "$DC_TYPE_FLOAT" || exitcode="$?"
  dc-tools::assert::equal "arg check $argument float" "NO_ERROR" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::argument::check argument "$DC_TYPE_INTEGER" || exitcode="$?"
  dc-tools::assert::equal "arg check $argument integer" "ARGUMENT_INVALID" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::argument::check argument "$DC_TYPE_UNSIGNED" || exitcode="$?"
  dc-tools::assert::equal "arg check $argument unsigned" "ARGUMENT_INVALID" "$(dc::error::lookup $exitcode)"

  argument="123.123"

  exitcode=0
  dc::argument::check argument "$DC_TYPE_FLOAT" || exitcode="$?"
  dc-tools::assert::equal "arg check $argument float" "NO_ERROR" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::argument::check argument "$DC_TYPE_INTEGER" || exitcode="$?"
  dc-tools::assert::equal "arg check $argument integer" "ARGUMENT_INVALID" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::argument::check argument "$DC_TYPE_UNSIGNED" || exitcode="$?"
  dc-tools::assert::equal "arg check $argument unsigned" "ARGUMENT_INVALID" "$(dc::error::lookup $exitcode)"

  argument="∞"

  exitcode=0
  dc::argument::check argument "$DC_TYPE_FLOAT" || exitcode="$?"
  dc-tools::assert::equal "arg check $argument notfloat" "ARGUMENT_INVALID" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::argument::check argument "$DC_TYPE_INTEGER" || exitcode="$?"
  dc-tools::assert::equal "arg check $argument notinteger" "ARGUMENT_INVALID" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::argument::check argument "$DC_TYPE_UNSIGNED" || exitcode="$?"
  dc-tools::assert::equal "arg check $argument notunsigned" "ARGUMENT_INVALID" "$(dc::error::lookup $exitcode)"
}

testArgumentCheckTypesBool() {
  local exitcode
  local argument

  # Booleans
  argument="true"

  exitcode=0
  dc::argument::check argument "$DC_TYPE_BOOLEAN" || exitcode="$?"
  dc-tools::assert::equal "arg check $argument bool" "NO_ERROR" "$(dc::error::lookup $exitcode)"

  argument="false"

  exitcode=0
  dc::argument::check argument "$DC_TYPE_BOOLEAN" || exitcode="$?"
  dc-tools::assert::equal "arg check $argument bool" "NO_ERROR" "$(dc::error::lookup $exitcode)"

  argument="∞"

  exitcode=0
  dc::argument::check argument "$DC_TYPE_BOOLEAN" || exitcode="$?"
  dc-tools::assert::equal "arg check $argument not bool" "ARGUMENT_INVALID" "$(dc::error::lookup $exitcode)"

  argument=1

  exitcode=0
  dc::argument::check argument "$DC_TYPE_BOOLEAN" || exitcode="$?"
  dc-tools::assert::equal "arg check $argument not bool" "ARGUMENT_INVALID" "$(dc::error::lookup $exitcode)"
}

testArgumentCheckTypesOther() {
  local exitcode
  local argument

  argument="abcdef123"

  exitcode=0
  dc::argument::check argument "$DC_TYPE_VARIABLE" || exitcode="$?"
  dc-tools::assert::equal "arg check $argument variable" "NO_ERROR" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::argument::check argument "$DC_TYPE_STRING" || exitcode="$?"
  dc-tools::assert::equal "arg check $argument string" "NO_ERROR" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::argument::check argument "$DC_TYPE_ALPHANUM" || exitcode="$?"
  dc-tools::assert::equal "arg check $argument alphanum" "NO_ERROR" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::argument::check argument "$DC_TYPE_HEX" || exitcode="$?"
  dc-tools::assert::equal "arg check $argument hex" "NO_ERROR" "$(dc::error::lookup $exitcode)"


  argument="∞"

  exitcode=0
  dc::argument::check argument "$DC_TYPE_VARIABLE" || exitcode="$?"
  dc-tools::assert::equal "arg check $argument not variable" "ARGUMENT_INVALID" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::argument::check argument "$DC_TYPE_STRING" || exitcode="$?"
  dc-tools::assert::equal "arg check $argument string" "NO_ERROR" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::argument::check argument "$DC_TYPE_ALPHANUM" || exitcode="$?"
  dc-tools::assert::equal "arg check $argument alphanum" "ARGUMENT_INVALID" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::argument::check argument "$DC_TYPE_HEX" || exitcode="$?"
  dc-tools::assert::equal "arg check $argument hex" "ARGUMENT_INVALID" "$(dc::error::lookup $exitcode)"

  # Survival conditions
  argument="abcdef123"
  exitcode=0
  PATH="" dc::argument::check argument "$DC_TYPE_VARIABLE" || exitcode="$?"
  dc-tools::assert::equal "arg check $argument variable" "NO_ERROR" "$(dc::error::lookup $exitcode)"

}
