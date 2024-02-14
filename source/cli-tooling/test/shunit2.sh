#! /bin/sh
# shellcheck disable=SC2086
# vim:et:ft=sh:sts=2:sw=2
#
# shUnit2 -- Unit testing framework for Unix shell scripts.
#
# Copyright 2008-2021 Kate Ward. All Rights Reserved.
# Released under the Apache 2.0 license.
# http://www.apache.org/licenses/LICENSE-2.0
#
# Author: kate.ward@forestent.com (Kate Ward)
# https://github.com/kward/shunit2
#
# shUnit2 is a xUnit based unit test framework for Bourne shell scripts. It is
# based on the popular JUnit unit testing framework for Java.
#
# `expr` may be antiquated, but it is the only solution in some cases.
#   shellcheck disable=SC2003
# Allow usage of legacy backticked `...` notation instead of $(...).
#   shellcheck disable=SC2006

# Return if shunit2 already loaded.
if test -n "${SHUNIT_VERSION:-}"; then
  exit 0
fi
SHUNIT_VERSION='2.1.9pre'

# Return values that scripts can use.
SHUNIT_TRUE=0
SHUNIT_FALSE=1
SHUNIT_ERROR=2

# Determine if `builtin` command exists.
__SHUNIT_BUILTIN='builtin'
# shellcheck disable=2039
if ! ("${__SHUNIT_BUILTIN}" echo 123 >/dev/null 2>&1); then
  __SHUNIT_BUILTIN=''
fi

# Determine some reasonable command defaults.
__SHUNIT_CMD_ECHO_ESC='echo -e'
# shellcheck disable=SC2039,SC3037
if ${__SHUNIT_BUILTIN} [ "`echo -e test`" = '-e test' ]; then
  __SHUNIT_CMD_ECHO_ESC='echo'
fi

# Commands a user can override if needed.
__SHUNIT_CMD_TPUT='tput'
SHUNIT_CMD_TPUT=${SHUNIT_CMD_TPUT:-${__SHUNIT_CMD_TPUT}}

# Enable color output. Options are 'auto', 'always', or 'never'.
SHUNIT_COLOR=${SHUNIT_COLOR:-auto}

#
# Internal constants.
#

__SHUNIT_MODE_SOURCED='sourced'
__SHUNIT_MODE_STANDALONE='standalone'
__SHUNIT_PARENT=${SHUNIT_PARENT:-$0}

# User provided test prefix to display in front of the name of the test being
# executed. Define by setting the SHUNIT_TEST_PREFIX variable.
__SHUNIT_TEST_PREFIX=${SHUNIT_TEST_PREFIX:-}

# ANSI colors.
__SHUNIT_ANSI_NONE='\033[0m'
__SHUNIT_ANSI_RED='\033[1;31m'
__SHUNIT_ANSI_GREEN='\033[1;32m'
__SHUNIT_ANSI_YELLOW='\033[1;33m'
__SHUNIT_ANSI_CYAN='\033[1;36m'

#
# Internal variables.
#

# Variables.
__shunit_lineno=''  # Line number of executed test.
__shunit_mode=${__SHUNIT_MODE_SOURCED}  # Operating mode.
__shunit_reportGenerated=${SHUNIT_FALSE}  # Is report generated.
__shunit_script=''  # Filename of unittest script (standalone mode).
__shunit_skip=${SHUNIT_FALSE}  # Is skipping enabled.
__shunit_suite=''  # Suite of tests to execute.
__shunit_clean=${SHUNIT_FALSE}  # _shunit_cleanup() was already called.

# ANSI colors (populated by _shunit_configureColor()).
__shunit_ansi_none=''
__shunit_ansi_red=''
__shunit_ansi_green=''
__shunit_ansi_yellow=''
__shunit_ansi_cyan=''

# Counts of tests.
__shunit_testSuccess=${SHUNIT_TRUE}
__shunit_testsTotal=0
__shunit_testsPassed=0
__shunit_testsFailed=0

# Counts of asserts.
__shunit_assertsTotal=0
__shunit_assertsPassed=0
__shunit_assertsFailed=0
__shunit_assertsSkipped=0

#
# Internal functions.
#

# Logging.
_shunit_warn() {
  ${__SHUNIT_CMD_ECHO_ESC} "${__shunit_ansi_yellow}shunit2:WARN${__shunit_ansi_none} $*" >&2
}
_shunit_error() {
  ${__SHUNIT_CMD_ECHO_ESC} "${__shunit_ansi_red}shunit2:ERROR${__shunit_ansi_none} $*" >&2
}
_shunit_fatal() {
  ${__SHUNIT_CMD_ECHO_ESC} "${__shunit_ansi_red}shunit2:FATAL${__shunit_ansi_none} $*" >&2
  exit ${SHUNIT_ERROR}
}

#
# Macros.
#

# shellcheck disable=SC2016,SC2089
_SHUNIT_LINENO_='eval __shunit_lineno=""; if ${__SHUNIT_BUILTIN} [ "${1:-}" = "--lineno" ] && ${__SHUNIT_BUILTIN} [ -n "${2:-}" ]; then __shunit_lineno="[${2}]"; shift 2; fi;'

#
# Setup.
#

# Specific shell checks.
if ${__SHUNIT_BUILTIN} [ -n "${ZSH_VERSION:-}" ]; then
  setopt |grep "^shwordsplit$" >/dev/null
  if ${__SHUNIT_BUILTIN} [ $? -ne ${SHUNIT_TRUE} ]; then
    _shunit_fatal 'zsh shwordsplit option is required for proper operation'
  fi
  if ${__SHUNIT_BUILTIN} [ -z "${SHUNIT_PARENT:-}" ]; then
    _shunit_fatal "zsh does not pass \$0 through properly. please declare \
\"SHUNIT_PARENT=\$0\" before calling shUnit2"
  fi
fi

# Set the constants readonly.
__shunit_constants=`set |grep '^__SHUNIT_' |cut -d= -f1`
echo "${__shunit_constants}" |grep '^Binary file' >/dev/null && \
    __shunit_constants=`set |grep -a '^__SHUNIT_' |cut -d= -f1`
for __shunit_const in ${__shunit_constants}; do
  if ${__SHUNIT_BUILTIN} [ -z "${ZSH_VERSION:-}" ]; then
    readonly "${__shunit_const}"
  else
    case ${ZSH_VERSION} in
      [123].*) readonly "${__shunit_const}" ;;
      *)
        # Declare readonly constants globally.
        # shellcheck disable=SC2039,SC3045
        readonly -g "${__shunit_const}"
    esac
  fi
done
unset __shunit_const __shunit_constants

#-----------------------------------------------------------------------------
# Assertion functions.
#

# Assert that two values are equal to one another.
#
# Args:
#   message: string: failure message [optional]
#   expected: string: expected value
#   actual: string: actual value
# Returns:
#   integer: success (TRUE/FALSE/ERROR constant)
assertEquals() {
  # shellcheck disable=SC2090
  ${_SHUNIT_LINENO_}
  if ${__SHUNIT_BUILTIN} [ $# -lt 2 -o $# -gt 3 ]; then
    _shunit_error "assertEquals() requires two or three arguments; $# given"
    _shunit_assertFail
    return ${SHUNIT_ERROR}
  fi
  if _shunit_shouldSkip; then
    return ${SHUNIT_TRUE}
  fi

  shunit_message_=${__shunit_lineno}
  if ${__SHUNIT_BUILTIN} [ $# -eq 3 ]; then
    shunit_message_="${shunit_message_}$1"
    shift
  fi
  shunit_expected_=$1
  shunit_actual_=$2

  shunit_return=${SHUNIT_TRUE}
  if ${__SHUNIT_BUILTIN} [ "${shunit_expected_}" = "${shunit_actual_}" ]; then
    _shunit_assertPass
  else
    failNotEquals "${shunit_message_}" "${shunit_expected_}" "${shunit_actual_}"
    shunit_return=${SHUNIT_FALSE}
  fi

  unset shunit_message_ shunit_expected_ shunit_actual_
  return ${shunit_return}
}
# shellcheck disable=SC2016,SC2034
_ASSERT_EQUALS_='eval assertEquals --lineno "${LINENO:-}"'

# Assert that two values are not equal to one another.
#
# Args:
#   message: string: failure message [optional]
#   expected: string: expected value
#   actual: string: actual value
# Returns:
#   integer: success (TRUE/FALSE/ERROR constant)
assertNotEquals() {
  # shellcheck disable=SC2090
  ${_SHUNIT_LINENO_}
  if ${__SHUNIT_BUILTIN} [ $# -lt 2 -o $# -gt 3 ]; then
    _shunit_error "assertNotEquals() requires two or three arguments; $# given"
    _shunit_assertFail
    return ${SHUNIT_ERROR}
  fi
  if _shunit_shouldSkip; then
    return ${SHUNIT_TRUE}
  fi

  shunit_message_=${__shunit_lineno}
  if ${__SHUNIT_BUILTIN} [ $# -eq 3 ]; then
    shunit_message_="${shunit_message_}$1"
    shift
  fi
  shunit_expected_=$1
  shunit_actual_=$2

  shunit_return=${SHUNIT_TRUE}
  if ${__SHUNIT_BUILTIN} [ "${shunit_expected_}" != "${shunit_actual_}" ]; then
    _shunit_assertPass
  else
    failSame "${shunit_message_}" "${shunit_expected_}" "${shunit_actual_}"
    shunit_return=${SHUNIT_FALSE}
  fi

  unset shunit_message_ shunit_expected_ shunit_actual_
  return ${shunit_return}
}
# shellcheck disable=SC2016,SC2034
_ASSERT_NOT_EQUALS_='eval assertNotEquals --lineno "${LINENO:-}"'

# Assert that a container contains a content.
#
# Args:
#   message: string: failure message [optional]
#   container: string: container to analyze
#   content: string: content to find
# Returns:
#   integer: success (TRUE/FALSE/ERROR constant)
assertContains() {
  # shellcheck disable=SC2090
  ${_SHUNIT_LINENO_}
  if ${__SHUNIT_BUILTIN} [ $# -lt 2 -o $# -gt 3 ]; then
    _shunit_error "assertContains() requires two or three arguments; $# given"
    _shunit_assertFail
    return ${SHUNIT_ERROR}
  fi
  if _shunit_shouldSkip; then
    return ${SHUNIT_TRUE}
  fi

  shunit_message_=${__shunit_lineno}
  if ${__SHUNIT_BUILTIN} [ $# -eq 3 ]; then
    shunit_message_="${shunit_message_}$1"
    shift
  fi
  shunit_container_=$1
  shunit_content_=$2
  shunit_return=${SHUNIT_TRUE}
  if echo "${shunit_container_}" |grep -F -- "${shunit_content_}" >/dev/null; then
    _shunit_assertPass
  else
    failNotFound "${shunit_message_}" "${shunit_content_}"
    shunit_return=${SHUNIT_FALSE}
  fi

  unset shunit_message_ shunit_container_ shunit_content_
  return ${shunit_return}
}
# shellcheck disable=SC2016,SC2034
_ASSERT_CONTAINS_='eval assertContains --lineno "${LINENO:-}"'

# Assert that a container does not contain a content.
#
# Args:
#   message: string: failure message [optional]
#   container: string: container to analyze
#   content: string: content to look for
# Returns:
#   integer: success (TRUE/FALSE/ERROR constant)
assertNotContains() {
  # shellcheck disable=SC2090
  ${_SHUNIT_LINENO_}
  if ${__SHUNIT_BUILTIN} [ $# -lt 2 -o $# -gt 3 ]; then
    _shunit_error "assertNotContains() requires two or three arguments; $# given"
    _shunit_assertFail
    return ${SHUNIT_ERROR}
  fi
  if _shunit_shouldSkip; then
    return ${SHUNIT_TRUE}
  fi

  shunit_message_=${__shunit_lineno}
  if ${__SHUNIT_BUILTIN} [ $# -eq 3 ]; then
    shunit_message_="${shunit_message_}$1"
    shift
  fi
  shunit_container_=$1
  shunit_content_=$2

  shunit_return=${SHUNIT_TRUE}
  if echo "$shunit_container_" | grep -F -- "$shunit_content_" > /dev/null; then
    failFound "${shunit_message_}" "${shunit_content_}"
    shunit_return=${SHUNIT_FALSE}
  else
    _shunit_assertPass
  fi

  unset shunit_message_ shunit_container_ shunit_content_
  return ${shunit_return}
}
# shellcheck disable=SC2016,SC2034
_ASSERT_NOT_CONTAINS_='eval assertNotContains --lineno "${LINENO:-}"'

# Assert that a value is null (i.e. an empty string).
#
# Args:
#   message: string: failure message [optional]
#   actual: string: actual value
# Returns:
#   integer: success (TRUE/FALSE/ERROR constant)
assertNull() {
  # shellcheck disable=SC2090
  ${_SHUNIT_LINENO_}
  if ${__SHUNIT_BUILTIN} [ $# -gt 2 ]; then
    # Allowing 0 arguments as $1 might actually be null.
    _shunit_error "assertNull() requires one or two arguments; $# given"
    _shunit_assertFail
    return ${SHUNIT_ERROR}
  fi
  if _shunit_shouldSkip; then
    return ${SHUNIT_TRUE}
  fi

  shunit_message_=${__shunit_lineno}
  if ${__SHUNIT_BUILTIN} [ $# -eq 2 ]; then
    shunit_message_="${shunit_message_}$1"
    shift
  fi

  ${__SHUNIT_BUILTIN} test -z "${1:-}"
  assertTrue "${shunit_message_}" $?
  shunit_return=$?

  unset shunit_message_
  return ${shunit_return}
}
# shellcheck disable=SC2016,SC2034
_ASSERT_NULL_='eval assertNull --lineno "${LINENO:-}"'

# Assert that a value is not null (i.e. a non-empty string).
#
# Args:
#   message: string: failure message [optional]
#   actual: string: actual value
# Returns:
#   integer: success (TRUE/FALSE/ERROR constant)
assertNotNull() {
  # shellcheck disable=SC2090
  ${_SHUNIT_LINENO_}
  if ${__SHUNIT_BUILTIN} [ $# -gt 2 ]; then
    # Allowing 0 arguments as $1 might actually be null.
    _shunit_error "assertNotNull() requires one or two arguments; $# given"
    _shunit_assertFail
    return ${SHUNIT_ERROR}
  fi
  if _shunit_shouldSkip; then
    return ${SHUNIT_TRUE}
  fi

  shunit_message_=${__shunit_lineno}
  if ${__SHUNIT_BUILTIN} [ $# -eq 2 ]; then
    shunit_message_="${shunit_message_}$1"
    shift
  fi

  ${__SHUNIT_BUILTIN} test -n "${1:-}"
  assertTrue "${shunit_message_}" $?
  shunit_return=$?

  unset shunit_message_
  return ${shunit_return}
}
# shellcheck disable=SC2016,SC2034
_ASSERT_NOT_NULL_='eval assertNotNull --lineno "${LINENO:-}"'

# Assert that two values are the same (i.e. equal to one another).
#
# Args:
#   message: string: failure message [optional]
#   expected: string: expected value
#   actual: string: actual value
# Returns:
#   integer: success (TRUE/FALSE/ERROR constant)
assertSame() {
  # shellcheck disable=SC2090
  ${_SHUNIT_LINENO_}
  if ${__SHUNIT_BUILTIN} [ $# -lt 2 -o $# -gt 3 ]; then
    _shunit_error "assertSame() requires two or three arguments; $# given"
    _shunit_assertFail
    return ${SHUNIT_ERROR}
  fi
  if _shunit_shouldSkip; then
    return ${SHUNIT_TRUE}
  fi

  shunit_message_=${__shunit_lineno}
  if ${__SHUNIT_BUILTIN} [ $# -eq 3 ]; then
    shunit_message_="${shunit_message_}$1"
    shift
  fi
  assertEquals "${shunit_message_}" "$1" "$2"
  shunit_return=$?

  unset shunit_message_
  return ${shunit_return}
}
# shellcheck disable=SC2016,SC2034
_ASSERT_SAME_='eval assertSame --lineno "${LINENO:-}"'

# Assert that two values are not the same (i.e. not equal to one another).
#
# Args:
#   message: string: failure message [optional]
#   expected: string: expected value
#   actual: string: actual value
# Returns:
#   integer: success (TRUE/FALSE/ERROR constant)
assertNotSame() {
  # shellcheck disable=SC2090
  ${_SHUNIT_LINENO_}
  if ${__SHUNIT_BUILTIN} [ $# -lt 2 -o $# -gt 3 ]; then
    _shunit_error "assertNotSame() requires two or three arguments; $# given"
    _shunit_assertFail
    return ${SHUNIT_ERROR}
  fi
  if _shunit_shouldSkip; then
    return ${SHUNIT_TRUE}
  fi

  shunit_message_=${__shunit_lineno}
  if ${__SHUNIT_BUILTIN} [ $# -eq 3 ]; then
    shunit_message_="${shunit_message_:-}$1"
    shift
  fi
  assertNotEquals "${shunit_message_}" "$1" "$2"
  shunit_return=$?

  unset shunit_message_
  return ${shunit_return}
}
# shellcheck disable=SC2016,SC2034
_ASSERT_NOT_SAME_='eval assertNotSame --lineno "${LINENO:-}"'

# Assert that a value or shell test condition is true.
#
# In shell, a value of 0 is true and a non-zero value is false. Any integer
# value passed can thereby be tested.
#
# Shell supports much more complicated tests though, and a means to support
# them was needed. As such, this function tests that conditions are true or
# false through evaluation rather than just looking for a true or false.
#
# The following test will succeed:
#   assertTrue 0
#   assertTrue "[ 34 -gt 23 ]"
# The following test will fail with a message:
#   assertTrue 123
#   assertTrue "test failed" "[ -r '/non/existent/file' ]"
#
# Args:
#   message: string: failure message [optional]
#   condition: string: integer value or shell conditional statement
# Returns:
#   integer: success (TRUE/FALSE/ERROR constant)
assertTrue() {
  # shellcheck disable=SC2090
  ${_SHUNIT_LINENO_}
  if ${__SHUNIT_BUILTIN} [ $# -lt 1 -o $# -gt 2 ]; then
    _shunit_error "assertTrue() takes one or two arguments; $# given"
    _shunit_assertFail
    return ${SHUNIT_ERROR}
  fi
  if _shunit_shouldSkip; then
    return ${SHUNIT_TRUE}
  fi

  shunit_message_=${__shunit_lineno}
  if ${__SHUNIT_BUILTIN} [ $# -eq 2 ]; then
    shunit_message_="${shunit_message_}$1"
    shift
  fi
  shunit_condition_=$1

  # See if condition is an integer, i.e. a return value.
  shunit_return=${SHUNIT_TRUE}
  if ${__SHUNIT_BUILTIN} [ -z "${shunit_condition_}" ]; then
    # Null condition.
    shunit_return=${SHUNIT_FALSE}
  elif (expr \( "${shunit_condition_}" + '0' \) '=' "${shunit_condition_}" >/dev/null 2>&1)
  then
    # Possible return value. Treating 0 as true, and non-zero as false.
    if ${__SHUNIT_BUILTIN} [ "${shunit_condition_}" -ne 0 ]; then
      shunit_return=${SHUNIT_FALSE}
    fi
  else
    # Hopefully... a condition.
    if ! eval "${shunit_condition_}" >/dev/null 2>&1; then
      shunit_return=${SHUNIT_FALSE}
    fi
  fi

  # Record the test.
  if ${__SHUNIT_BUILTIN} [ ${shunit_return} -eq ${SHUNIT_TRUE} ]; then
    _shunit_assertPass
  else
    _shunit_assertFail "${shunit_message_}"
  fi

  unset shunit_message_ shunit_condition_
  return ${shunit_return}
}
# shellcheck disable=SC2016,SC2034
_ASSERT_TRUE_='eval assertTrue --lineno "${LINENO:-}"'

# Assert that a value or shell test condition is false.
#
# In shell, a value of 0 is true and a non-zero value is false. Any integer
# value passed can thereby be tested.
#
# Shell supports much more complicated tests though, and a means to support
# them was needed. As such, this function tests that conditions are true or
# false through evaluation rather than just looking for a true or false.
#
# The following test will succeed:
#   assertFalse 1
#   assertFalse "[ 'apples' = 'oranges' ]"
# The following test will fail with a message:
#   assertFalse 0
#   assertFalse "test failed" "[ 1 -eq 1 -a 2 -eq 2 ]"
#
# Args:
#   message: string: failure message [optional]
#   condition: string: integer value or shell conditional statement
# Returns:
#   integer: success (TRUE/FALSE/ERROR constant)
assertFalse() {
  # shellcheck disable=SC2090
  ${_SHUNIT_LINENO_}
  if ${__SHUNIT_BUILTIN} [ $# -lt 1 -o $# -gt 2 ]; then
    _shunit_error "assertFalse() requires one or two arguments; $# given"
    _shunit_assertFail
    return ${SHUNIT_ERROR}
  fi
  if _shunit_shouldSkip; then
    return ${SHUNIT_TRUE}
  fi

  shunit_message_=${__shunit_lineno}
  if ${__SHUNIT_BUILTIN} [ $# -eq 2 ]; then
    shunit_message_="${shunit_message_}$1"
    shift
  fi
  shunit_condition_=$1

  # See if condition is an integer, i.e. a return value.
  shunit_return=${SHUNIT_TRUE}
  if ${__SHUNIT_BUILTIN} [ -z "${shunit_condition_}" ]; then
    # Null condition.
    shunit_return=${SHUNIT_TRUE}
  elif (expr \( "${shunit_condition_}" + '0' \) '=' "${shunit_condition_}" >/dev/null 2>&1); then
    # Possible return value. Treating 0 as true, and non-zero as false.
    if ${__SHUNIT_BUILTIN} [ "${shunit_condition_}" -eq 0 ]; then
      shunit_return=${SHUNIT_FALSE}
    fi
  else
    # Hopefully... a condition.
    # shellcheck disable=SC2086
    if eval ${shunit_condition_} >/dev/null 2>&1; then
      shunit_return=${SHUNIT_FALSE}
    fi
  fi

  # Record the test.
  if ${__SHUNIT_BUILTIN} [ "${shunit_return}" -eq "${SHUNIT_TRUE}" ]; then
    _shunit_assertPass
  else
    _shunit_assertFail "${shunit_message_}"
  fi

  unset shunit_message_ shunit_condition_
  return "${shunit_return}"
}
# shellcheck disable=SC2016,SC2034
_ASSERT_FALSE_='eval assertFalse --lineno "${LINENO:-}"'

#-----------------------------------------------------------------------------
# Failure functions.
#

# Records a test failure.
#
# Args:
#   message: string: failure message [optional]
# Returns:
#   integer: success (TRUE/FALSE/ERROR constant)
fail() {
  # shellcheck disable=SC2090
  ${_SHUNIT_LINENO_}
  if ${__SHUNIT_BUILTIN} [ $# -gt 1 ]; then
    _shunit_error "fail() requires zero or one arguments; $# given"
    return ${SHUNIT_ERROR}
  fi
  if _shunit_shouldSkip; then
    return ${SHUNIT_TRUE}
  fi

  shunit_message_=${__shunit_lineno}
  if ${__SHUNIT_BUILTIN} [ $# -eq 1 ]; then
    shunit_message_="${shunit_message_}$1"
    shift
  fi

  _shunit_assertFail "${shunit_message_}"

  unset shunit_message_
  return ${SHUNIT_FALSE}
}
# shellcheck disable=SC2016,SC2034
_FAIL_='eval fail --lineno "${LINENO:-}"'

# Records a test failure, stating two values were not equal.
#
# Args:
#   message: string: failure message [optional]
#   expected: string: expected value
#   actual: string: actual value
# Returns:
#   integer: success (TRUE/FALSE/ERROR constant)
failNotEquals() {
  # shellcheck disable=SC2090
  ${_SHUNIT_LINENO_}
  if ${__SHUNIT_BUILTIN} [ $# -lt 2 -o $# -gt 3 ]; then
    _shunit_error "failNotEquals() requires one or two arguments; $# given"
    return ${SHUNIT_ERROR}
  fi
  if _shunit_shouldSkip; then
    return ${SHUNIT_TRUE}
  fi

  shunit_message_=${__shunit_lineno}
  if ${__SHUNIT_BUILTIN} [ $# -eq 3 ]; then
    shunit_message_="${shunit_message_}$1"
    shift
  fi
  shunit_expected_=$1
  shunit_actual_=$2

  shunit_message_=${shunit_message_%% }
  _shunit_assertFail "${shunit_message_:+${shunit_message_} }expected:<${shunit_expected_}> but was:<${shunit_actual_}>"

  unset shunit_message_ shunit_expected_ shunit_actual_
  return ${SHUNIT_FALSE}
}
# shellcheck disable=SC2016,SC2034
_FAIL_NOT_EQUALS_='eval failNotEquals --lineno "${LINENO:-}"'

# Records a test failure, stating a value was found.
#
# Args:
#   message: string: failure message [optional]
#   content: string: found value
# Returns:
#   integer: success (TRUE/FALSE/ERROR constant)
failFound() {
  # shellcheck disable=SC2090
  ${_SHUNIT_LINENO_}
  if ${__SHUNIT_BUILTIN} [ $# -lt 1 -o $# -gt 2 ]; then
    _shunit_error "failFound() requires one or two arguments; $# given"
    return ${SHUNIT_ERROR}
  fi
  if _shunit_shouldSkip; then
    return ${SHUNIT_TRUE}
  fi

  shunit_message_=${__shunit_lineno}
  if ${__SHUNIT_BUILTIN} [ $# -eq 2 ]; then
    shunit_message_="${shunit_message_}$1"
    shift
  fi
  shunit_content_=$1

  shunit_message_=${shunit_message_%% }
  _shunit_assertFail "${shunit_message_:+${shunit_message_} }found:<${shunit_content_}>"

  unset shunit_message_ shunit_content_
  return ${SHUNIT_FALSE}
}
# shellcheck disable=SC2016,SC2034
_FAIL_FOUND_='eval failFound --lineno "${LINENO:-}"'

# Records a test failure, stating a content was not found.
#
# Args:
#   message: string: failure message [optional]
#   content: string: content not found
# Returns:
#   integer: success (TRUE/FALSE/ERROR constant)
failNotFound() {
  # shellcheck disable=SC2090
  ${_SHUNIT_LINENO_}
  if ${__SHUNIT_BUILTIN} [ $# -lt 1 -o $# -gt 2 ]; then
    _shunit_error "failNotFound() requires one or two arguments; $# given"
    return ${SHUNIT_ERROR}
  fi
  if _shunit_shouldSkip; then
    return ${SHUNIT_TRUE}
  fi

  shunit_message_=${__shunit_lineno}
  if ${__SHUNIT_BUILTIN} [ $# -eq 2 ]; then
    shunit_message_="${shunit_message_}$1"
    shift
  fi
  shunit_content_=$1

  shunit_message_=${shunit_message_%% }
  _shunit_assertFail "${shunit_message_:+${shunit_message_} }not found:<${shunit_content_}>"

  unset shunit_message_ shunit_content_
  return ${SHUNIT_FALSE}
}
# shellcheck disable=SC2016,SC2034
_FAIL_NOT_FOUND_='eval failNotFound --lineno "${LINENO:-}"'

# Records a test failure, stating two values should have been the same.
#
# Args:
#   message: string: failure message [optional]
#   expected: string: expected value
#   actual: string: actual value
# Returns:
#   integer: success (TRUE/FALSE/ERROR constant)
failSame() {
  # shellcheck disable=SC2090
  ${_SHUNIT_LINENO_}
  if ${__SHUNIT_BUILTIN} [ $# -lt 2 -o $# -gt 3 ]; then
    _shunit_error "failSame() requires two or three arguments; $# given"
    return ${SHUNIT_ERROR}
  fi
  if _shunit_shouldSkip; then
    return ${SHUNIT_TRUE}
  fi

  shunit_message_=${__shunit_lineno}
  if ${__SHUNIT_BUILTIN} [ $# -eq 3 ]; then
    shunit_message_="${shunit_message_}$1"
    shift
  fi

  shunit_message_=${shunit_message_%% }
  _shunit_assertFail "${shunit_message_:+${shunit_message_} }expected not same"

  unset shunit_message_
  return ${SHUNIT_FALSE}
}
# shellcheck disable=SC2016,SC2034
_FAIL_SAME_='eval failSame --lineno "${LINENO:-}"'

# Records a test failure, stating two values were not equal.
#
# This is functionally equivalent to calling failNotEquals().
#
# Args:
#   message: string: failure message [optional]
#   expected: string: expected value
#   actual: string: actual value
# Returns:
#   integer: success (TRUE/FALSE/ERROR constant)
failNotSame() {
  # shellcheck disable=SC2090
  ${_SHUNIT_LINENO_}
  if ${__SHUNIT_BUILTIN} [ $# -lt 2 -o $# -gt 3 ]; then
    _shunit_error "failNotSame() requires one or two arguments; $# given"
    return ${SHUNIT_ERROR}
  fi
  if _shunit_shouldSkip; then
    return ${SHUNIT_TRUE}
  fi

  shunit_message_=${__shunit_lineno}
  if ${__SHUNIT_BUILTIN} [ $# -eq 3 ]; then
    shunit_message_="${shunit_message_}$1"
    shift
  fi
  failNotEquals "${shunit_message_}" "$1" "$2"
  shunit_return=$?

  unset shunit_message_
  return ${shunit_return}
}
# shellcheck disable=SC2016,SC2034
_FAIL_NOT_SAME_='eval failNotSame --lineno "${LINENO:-}"'

#-----------------------------------------------------------------------------
# Skipping functions.
#

# Force remaining assert and fail functions to be "skipped".
#
# This function forces the remaining assert and fail functions to be "skipped",
# i.e. they will have no effect. Each function skipped will be recorded so that
# the total of asserts and fails will not be altered.
#
# Args:
#   message: string: message to provide to user [optional]
startSkipping() {
  if ${__SHUNIT_BUILTIN} [ $# -gt 0 ]; then _shunit_warn "[skipping] $*"; fi
  __shunit_skip=${SHUNIT_TRUE}
}

# Resume the normal recording behavior of assert and fail calls.
#
# Args:
#   None
endSkipping() { __shunit_skip=${SHUNIT_FALSE}; }

# Returns the state of assert and fail call skipping.
#
# Args:
#   None
# Returns:
#   boolean: (TRUE/FALSE constant)
isSkipping() { return ${__shunit_skip}; }

#-----------------------------------------------------------------------------
# Suite functions.
#

# Stub. This function should contains all unit test calls to be made.
#
# DEPRECATED (as of 2.1.0)
#
# This function can be optionally overridden by the user in their test suite.
#
# If this function exists, it will be called when shunit2 is sourced. If it
# does not exist, shunit2 will search the parent script for all functions
# beginning with the word 'test', and they will be added dynamically to the
# test suite.
#
# This function should be overridden by the user in their unit test suite.
# Note: see _shunit_mktempFunc() for actual implementation
#
# Args:
#   None
#suite() { :; }  # DO NOT UNCOMMENT THIS FUNCTION

# Adds a function name to the list of tests schedule for execution.
#
# This function should only be called from within the suite() function.
#
# Args:
#   function: string: name of a function to add to current unit test suite
suite_addTest() {
  shunit_func_=${1:-}

  __shunit_suite="${__shunit_suite:+${__shunit_suite} }${shunit_func_}"
  __shunit_testsTotal=`expr ${__shunit_testsTotal} + 1`

  unset shunit_func_
}

# Stub. This function will be called once before any tests are run.
#
# Common one-time environment preparation tasks shared by all tests can be
# defined here.
#
# This function should be overridden by the user in their unit test suite.
# Note: see _shunit_mktempFunc() for actual implementation
#
# Args:
#   None
#oneTimeSetUp() { :; }  # DO NOT UNCOMMENT THIS FUNCTION

# Stub. This function will be called once after all tests are finished.
#
# Common one-time environment cleanup tasks shared by all tests can be defined
# here.
#
# This function should be overridden by the user in their unit test suite.
# Note: see _shunit_mktempFunc() for actual implementation
#
# Args:
#   None
#oneTimeTearDown() { :; }  # DO NOT UNCOMMENT THIS FUNCTION

# Stub. This function will be called before each test is run.
#
# Common environment preparation tasks shared by all tests can be defined here.
#
# This function should be overridden by the user in their unit test suite.
# Note: see _shunit_mktempFunc() for actual implementation
#
# Args:
#   None
#setUp() { :; }  # DO NOT UNCOMMENT THIS FUNCTION

# Note: see _shunit_mktempFunc() for actual implementation
# Stub. This function will be called after each test is run.
#
# Common environment cleanup tasks shared by all tests can be defined here.
#
# This function should be overridden by the user in their unit test suite.
# Note: see _shunit_mktempFunc() for actual implementation
#
# Args:
#   None
#tearDown() { :; }  # DO NOT UNCOMMENT THIS FUNCTION

#------------------------------------------------------------------------------
# Internal shUnit2 functions.
#

# Create a temporary directory to store various run-time files in.
#
# This function is a cross-platform temporary directory creation tool. Not all
# OSes have the `mktemp` function, so one is included here.
#
# Args:
#   None
# Outputs:
#   string: the temporary directory that was created
_shunit_mktempDir() {
  # Try the standard `mktemp` function.
  if ( exec mktemp -dqt shunit.XXXXXX 2>/dev/null ); then
    return
  fi

  # The standard `mktemp` didn't work. Use our own.
  # shellcheck disable=SC2039,SC3028
  if ${__SHUNIT_BUILTIN} [ -r '/dev/urandom' -a -x '/usr/bin/od' ]; then
    _shunit_random_=`/usr/bin/od -vAn -N4 -tx4 </dev/urandom |command sed 's/^[^0-9a-f]*//'`
  elif ${__SHUNIT_BUILTIN} [ -n "${RANDOM:-}" ]; then
    # $RANDOM works
    _shunit_random_=${RANDOM}${RANDOM}${RANDOM}$$
  else
    # `$RANDOM` doesn't work.
    _shunit_date_=`date '+%Y%m%d%H%M%S'`
    _shunit_random_=`expr "${_shunit_date_}" / $$`
  fi

  _shunit_tmpDir_="${TMPDIR:-/tmp}/shunit.${_shunit_random_}"
  if ! ( umask 077 && command mkdir "${_shunit_tmpDir_}" ); then
    _shunit_fatal 'could not create temporary directory! exiting'
  fi

  echo "${_shunit_tmpDir_}"
  unset _shunit_date_ _shunit_random_ _shunit_tmpDir_
}

# This function is here to work around issues in Cygwin.
#
# Args:
#   None
_shunit_mktempFunc() {
  for _shunit_func_ in oneTimeSetUp oneTimeTearDown setUp tearDown suite noexec
  do
    _shunit_file_="${__shunit_tmpDir}/${_shunit_func_}"
    command cat <<EOF >"${_shunit_file_}"
#! /bin/sh
exit ${SHUNIT_TRUE}
EOF
    command chmod +x "${_shunit_file_}"
  done

  unset _shunit_file_
}

# Final cleanup function to leave things as we found them.
#
# Besides removing the temporary directory, this function is in charge of the
# final exit code of the unit test. The exit code is based on how the script
# was ended (e.g. normal exit, or via Ctrl-C).
#
# Args:
#   name: string: name of the trap called (specified when trap defined)
_shunit_cleanup() {
  _shunit_name_=$1

  _shunit_signal_=0
  case "${_shunit_name_}" in
    EXIT) ;;
    INT) _shunit_signal_=130 ;;  # 2+128
    TERM) _shunit_signal_=143 ;;  # 15+128
    *)
      _shunit_error "unrecognized trap value (${_shunit_name_})"
      ;;
  esac
  if ${__SHUNIT_BUILTIN} [ "${_shunit_name_}" != 'EXIT' ]; then
    _shunit_warn "trapped and now handling the (${_shunit_name_}) signal"
  fi

  # Do our work.
  if ${__SHUNIT_BUILTIN} [ ${__shunit_clean} -eq ${SHUNIT_FALSE} ]; then
    # Ensure tear downs are only called once.
    __shunit_clean=${SHUNIT_TRUE}

    tearDown || _shunit_warn 'tearDown() returned non-zero return code.'
    oneTimeTearDown || \
        _shunit_warn 'oneTimeTearDown() returned non-zero return code.'

    command rm -fr "${__shunit_tmpDir}"
  fi

  if ${__SHUNIT_BUILTIN} [ "${_shunit_name_}" != 'EXIT' ]; then
    # Handle all non-EXIT signals.
    trap - 0  # Disable EXIT trap.
    exit ${_shunit_signal_}
  elif ${__SHUNIT_BUILTIN} [ ${__shunit_reportGenerated} -eq ${SHUNIT_FALSE} ]; then
    _shunit_assertFail 'unknown failure encountered running a test'
    _shunit_generateReport
    exit ${SHUNIT_ERROR}
  fi

  unset _shunit_name_ _shunit_signal_
}

# configureColor based on user color preference.
#
# Args:
#   color: string: color mode (one of `always`, `auto`, or `never`).
_shunit_configureColor() {
  _shunit_color_=${SHUNIT_FALSE}  # By default, no color.
  case $1 in
    'always') _shunit_color_=${SHUNIT_TRUE} ;;
    'auto')
      if ${__SHUNIT_BUILTIN} [ "`_shunit_colors`" -ge 8 ]; then
        _shunit_color_=${SHUNIT_TRUE}
      fi
      ;;
    'never'|'none') ;;  # Support 'none' to support legacy usage.
    *) _shunit_fatal "unrecognized color option '$1'" ;;
  esac

  # shellcheck disable=SC2254
  case ${_shunit_color_} in
    ${SHUNIT_TRUE})
      __shunit_ansi_none=${__SHUNIT_ANSI_NONE}
      __shunit_ansi_red=${__SHUNIT_ANSI_RED}
      __shunit_ansi_green=${__SHUNIT_ANSI_GREEN}
      __shunit_ansi_yellow=${__SHUNIT_ANSI_YELLOW}
      __shunit_ansi_cyan=${__SHUNIT_ANSI_CYAN}
      ;;
    ${SHUNIT_FALSE})
      __shunit_ansi_none=''
      __shunit_ansi_red=''
      __shunit_ansi_green=''
      __shunit_ansi_yellow=''
      __shunit_ansi_cyan=''
      ;;
  esac

  unset _shunit_color_ _shunit_tput_
}

# colors returns the number of supported colors for the TERM.
_shunit_colors() {
  if _shunit_tput_=`${SHUNIT_CMD_TPUT} colors 2>/dev/null`; then
    echo "${_shunit_tput_}"
  else
    echo 16
  fi
  unset _shunit_tput_
}

# The actual running of the tests happens here.
#
# Args:
#   None
_shunit_execSuite() {
  for _shunit_test_ in ${__shunit_suite}; do
    __shunit_testSuccess=${SHUNIT_TRUE}

    # Disable skipping.
    endSkipping

    # Execute the per-test setUp() function.
    if ! setUp; then
      _shunit_fatal "setUp() returned non-zero return code."
    fi

    # Execute the test.
    echo "${__SHUNIT_TEST_PREFIX}${_shunit_test_}"
    # shellcheck disable=SC2086
    if ! eval ${_shunit_test_}; then
      _shunit_error "${_shunit_test_}() returned non-zero return code."
      __shunit_testSuccess=${SHUNIT_ERROR}
    fi

    # Execute the per-test tearDown() function.
    if ! tearDown; then
      _shunit_fatal "tearDown() returned non-zero return code."
    fi

    # Update stats.
    if ${__SHUNIT_BUILTIN} [ ${__shunit_testSuccess} -eq ${SHUNIT_TRUE} ]; then
      __shunit_testsPassed=`expr ${__shunit_testsPassed} + 1`
    else
      __shunit_testsFailed=`expr ${__shunit_testsFailed} + 1`
    fi
  done

  unset _shunit_test_
}

# Generates the user friendly report with appropriate OK/FAILED message.
#
# Args:
#   None
# Output:
#   string: the report of successful and failed tests, as well as totals.
_shunit_generateReport() {
  if ${__SHUNIT_BUILTIN} [ "${__shunit_reportGenerated}" -eq ${SHUNIT_TRUE} ]; then
    return
  fi

  _shunit_ok_=${SHUNIT_TRUE}

  # If no exit code was provided, determine an appropriate one.
  if ${__SHUNIT_BUILTIN} [ "${__shunit_testsFailed}" -gt 0 -o ${__shunit_testSuccess} -eq ${SHUNIT_FALSE} ]; then
    _shunit_ok_=${SHUNIT_FALSE}
  fi

  echo
  _shunit_msg_="Ran ${__shunit_ansi_cyan}${__shunit_testsTotal}${__shunit_ansi_none}"
  if ${__SHUNIT_BUILTIN} [ "${__shunit_testsTotal}" -eq 1 ]; then
    ${__SHUNIT_CMD_ECHO_ESC} "${_shunit_msg_} test."
  else
    ${__SHUNIT_CMD_ECHO_ESC} "${_shunit_msg_} tests."
  fi

  if ${__SHUNIT_BUILTIN} [ ${_shunit_ok_} -eq ${SHUNIT_TRUE} ]; then
    _shunit_msg_="${__shunit_ansi_green}OK${__shunit_ansi_none}"
    if ${__SHUNIT_BUILTIN} [ "${__shunit_assertsSkipped}" -gt 0 ]; then
      _shunit_msg_="${_shunit_msg_} (${__shunit_ansi_yellow}skipped=${__shunit_assertsSkipped}${__shunit_ansi_none})"
    fi
  else
    _shunit_msg_="${__shunit_ansi_red}FAILED${__shunit_ansi_none}"
    _shunit_msg_="${_shunit_msg_} (${__shunit_ansi_red}failures=${__shunit_assertsFailed}${__shunit_ansi_none}"
    if ${__SHUNIT_BUILTIN} [ "${__shunit_assertsSkipped}" -gt 0 ]; then
      _shunit_msg_="${_shunit_msg_},${__shunit_ansi_yellow}skipped=${__shunit_assertsSkipped}${__shunit_ansi_none}"
    fi
    _shunit_msg_="${_shunit_msg_})"
  fi

  echo
  ${__SHUNIT_CMD_ECHO_ESC} "${_shunit_msg_}"
  __shunit_reportGenerated=${SHUNIT_TRUE}

  unset _shunit_msg_ _shunit_ok_
}

# Test for whether a function should be skipped.
#
# Args:
#   None
# Returns:
#   boolean: whether the test should be skipped (TRUE/FALSE constant)
_shunit_shouldSkip() {
  if ${__SHUNIT_BUILTIN} test ${__shunit_skip} -eq ${SHUNIT_FALSE}; then
    return ${SHUNIT_FALSE}
  fi
  _shunit_assertSkip
}

# Records a successful test.
#
# Args:
#   None
_shunit_assertPass() {
  __shunit_assertsPassed=`expr ${__shunit_assertsPassed} + 1`
  __shunit_assertsTotal=`expr ${__shunit_assertsTotal} + 1`
}

# Records a test failure.
#
# Args:
#   message: string: failure message to provide user
_shunit_assertFail() {
  __shunit_testSuccess=${SHUNIT_FALSE}
  _shunit_incFailedCount

  if ${__SHUNIT_BUILTIN} [ $# -gt 0 ]; then
    ${__SHUNIT_CMD_ECHO_ESC} "${__shunit_ansi_red}ASSERT:${__shunit_ansi_none}$*"
  fi
}

# Increment the count of failed asserts.
#
# Args:
#   none
_shunit_incFailedCount() {
  __shunit_assertsFailed=`expr "${__shunit_assertsFailed}" + 1`
  __shunit_assertsTotal=`expr "${__shunit_assertsTotal}" + 1`
}

# Records a skipped test.
#
# Args:
#   None
_shunit_assertSkip() {
  __shunit_assertsSkipped=`expr "${__shunit_assertsSkipped}" + 1`
  __shunit_assertsTotal=`expr "${__shunit_assertsTotal}" + 1`
}

# Dump the current test metrics.
#
# Args:
#   none
_shunit_metrics() {
  echo "< \
total: ${__shunit_assertsTotal} \
passed: ${__shunit_assertsPassed} \
failed: ${__shunit_assertsFailed} \
skipped: ${__shunit_assertsSkipped} \
>"
}

# Prepare a script filename for sourcing.
#
# Args:
#   script: string: path to a script to source
# Returns:
#   string: filename prefixed with ./ (if necessary)
_shunit_prepForSourcing() {
  _shunit_script_=$1
  case "${_shunit_script_}" in
    /*|./*) echo "${_shunit_script_}" ;;
    *) echo "./${_shunit_script_}" ;;
  esac
  unset _shunit_script_
}

# Extract list of functions to run tests against.
#
# Args:
#   script: string: name of script to extract functions from
# Returns:
#   string: of function names
_shunit_extractTestFunctions() {
  _shunit_script_=$1

  # Extract the lines with test function names, strip of anything besides the
  # function name, and output everything on a single line.
  _shunit_regex_='^\s*((function test[A-Za-z0-9_-]*)|(test[A-Za-z0-9_-]* *\(\)))'
  # shellcheck disable=SC2196
  egrep "${_shunit_regex_}" "${_shunit_script_}" \
  |command sed 's/^[^A-Za-z0-9_-]*//;s/^function //;s/\([A-Za-z0-9_-]*\).*/\1/g' \
  |xargs

  unset _shunit_regex_ _shunit_script_
}

#------------------------------------------------------------------------------
# Main.
#

# Determine the operating mode.
if ${__SHUNIT_BUILTIN} [ $# -eq 0 -o "${1:-}" = '--' ]; then
  __shunit_script=${__SHUNIT_PARENT}
  __shunit_mode=${__SHUNIT_MODE_SOURCED}
else
  __shunit_script=$1
  if ! ${__SHUNIT_BUILTIN} [ -r "${__shunit_script}" ]; then
    _shunit_fatal "unable to read from ${__shunit_script}"
  fi
  __shunit_mode=${__SHUNIT_MODE_STANDALONE}
fi

# Create a temporary storage location.
__shunit_tmpDir=`_shunit_mktempDir`

# Provide a public temporary directory for unit test scripts.
# TODO(kward): document this.
SHUNIT_TMPDIR="${__shunit_tmpDir}/tmp"
if ! command mkdir "${SHUNIT_TMPDIR}"; then
  _shunit_fatal "error creating SHUNIT_TMPDIR '${SHUNIT_TMPDIR}'"
fi

# Configure traps to clean up after ourselves.
trap '_shunit_cleanup EXIT' 0
trap '_shunit_cleanup INT' 2
trap '_shunit_cleanup TERM' 15

# Create phantom functions to work around issues with Cygwin.
_shunit_mktempFunc
PATH="${__shunit_tmpDir}:${PATH}"

# Make sure phantom functions are executable. This will bite if `/tmp` (or the
# current `$TMPDIR`) points to a path on a partition that was mounted with the
# 'noexec' option. The noexec command was created with `_shunit_mktempFunc()`.
noexec 2>/dev/null || _shunit_fatal \
    'Please declare TMPDIR with path on partition with exec permission.'

# We must manually source the tests in standalone mode.
if ${__SHUNIT_BUILTIN} [ "${__shunit_mode}" = "${__SHUNIT_MODE_STANDALONE}" ]; then
  # shellcheck disable=SC1090
  ${__SHUNIT_BUILTIN} . "`_shunit_prepForSourcing \"${__shunit_script}\"`"
fi

# Configure default output coloring behavior.
_shunit_configureColor "${SHUNIT_COLOR}"

# Execute the oneTimeSetUp function (if it exists).
if ! oneTimeSetUp; then
  _shunit_fatal "oneTimeSetUp() returned non-zero return code."
fi

# Command line selected tests or suite selected tests
if ${__SHUNIT_BUILTIN} [ "$#" -ge 2 ]; then
  # Argument $1 is either the filename of tests or '--'; either way, skip it.
  shift
  # Remaining arguments ($2 .. $#) are assumed to be test function names.
  # Interate through all remaining args in "$@" in a POSIX (likely portable) way.
  # Helpful tip: https://unix.stackexchange.com/questions/314032/how-to-use-arguments-like-1-2-in-a-for-loop
  for _shunit_arg_ do
    suite_addTest "${_shunit_arg_}"
  done
  unset _shunit_arg_
else
  # Execute the suite function defined in the parent test script.
  # DEPRECATED as of 2.1.0.
  suite
fi

# If no tests or suite specified, dynamically build a list of functions.
if ${__SHUNIT_BUILTIN} [ -z "${__shunit_suite}" ]; then
  shunit_funcs_=`_shunit_extractTestFunctions "${__shunit_script}"`
  for shunit_func_ in ${shunit_funcs_}; do
    suite_addTest "${shunit_func_}"
  done
fi
unset shunit_func_ shunit_funcs_

# Execute the suite of unit tests.
_shunit_execSuite

# Execute the oneTimeTearDown function (if it exists).
if ! oneTimeTearDown; then
  _shunit_fatal "oneTimeTearDown() returned non-zero return code."
fi

# Generate a report summary.
_shunit_generateReport

# That's it folks.
if ! ${__SHUNIT_BUILTIN} [ "${__shunit_testsFailed}" -eq 0 ]; then
  exit ${SHUNIT_FALSE}
fi
