#!/usr/bin/env bash


testArgumentCheck(){
  local foo="123"

  dc::argument::check "nonexistent" "[0-9]"
  dc-tools::assert::equal "arg check non existent" "ERROR_ARGUMENT_INVALID" "$(dc::error::lookup $?)"

  dc::argument::check foo ""
  dc-tools::assert::equal "arg check no validation" "0" "$?"

  # Float and ints
  foo="123"
  dc::argument::check foo "$DC_TYPE_INTEGER"
  dc-tools::assert::equal "arg check $foo integer" "0" "$?"
  dc::argument::check foo "$DC_TYPE_UNSIGNED"
  dc-tools::assert::equal "arg check $foo unsigned" "0" "$?"
  dc::argument::check foo "$DC_TYPE_FLOAT"
  dc-tools::assert::equal "arg check $foo float" "0" "$?"

  foo="-123"
  dc::argument::check foo "$DC_TYPE_INTEGER"
  dc-tools::assert::equal "arg check $foo integer" "0" "$?"
  dc::argument::check foo "$DC_TYPE_FLOAT"
  dc-tools::assert::equal "arg check $foo float" "0" "$?"

  foo="-123.123"
  dc::argument::check foo "$DC_TYPE_FLOAT"
  dc-tools::assert::equal "arg check $foo float" "0" "$?"

  foo="123.123"
  dc::argument::check foo "$DC_TYPE_FLOAT"
  dc-tools::assert::equal "arg check $foo float" "0" "$?"

  # Booleans
  foo="true"
  dc::argument::check foo "$DC_TYPE_BOOLEAN"
  dc-tools::assert::equal "arg check $foo bool" "0" "$?"

  foo="false"
  dc::argument::check foo "$DC_TYPE_BOOLEAN"
  dc-tools::assert::equal "arg check $foo bool" "0" "$?"

  foo="thisIsAVariable123"
  dc::argument::check foo "$DC_TYPE_VARIABLE"
  dc-tools::assert::equal "arg check $foo variable" "0" "$?"

  foo="∞"
  dc::argument::check foo "$DC_TYPE_VARIABLE"
  dc-tools::assert::equal "arg check $foo not variable" "ERROR_ARGUMENT_INVALID" "$(dc::error::lookup $?)"
  dc::argument::check foo "$DC_TYPE_BOOLEAN"
  dc-tools::assert::equal "arg check $foo not bool" "ERROR_ARGUMENT_INVALID" "$(dc::error::lookup $?)"
  dc::argument::check foo "$DC_TYPE_FLOAT"
  dc-tools::assert::equal "arg check $foo notfloat" "ERROR_ARGUMENT_INVALID" "$(dc::error::lookup $?)"
  dc::argument::check foo "$DC_TYPE_INTEGER"
  dc-tools::assert::equal "arg check $foo notinteger" "ERROR_ARGUMENT_INVALID" "$(dc::error::lookup $?)"
  dc::argument::check foo "$DC_TYPE_UNSIGNED"
  dc-tools::assert::equal "arg check $foo notunsigned" "ERROR_ARGUMENT_INVALID" "$(dc::error::lookup $?)"

}
