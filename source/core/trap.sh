#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

##########################################################################
# Trap
# ------
# Error handling
##########################################################################


# Mechanism to register "cleanup" methods

dc::trap::register(){
  _DC_PRIVATE_TRAP_CLEAN+=( "$1" )
}

dc::trap::setup(){
  trap '_dc::private::trap::signal::HUP     "$LINENO" "$?" "$BASH_COMMAND"' 1
  trap '_dc::private::trap::signal::INT     "$LINENO" "$?" "$BASH_COMMAND"' 2
  trap '_dc::private::trap::signal::QUIT    "$LINENO" "$?" "$BASH_COMMAND"' 3
  trap '_dc::private::trap::signal::ABRT    "$LINENO" "$?" "$BASH_COMMAND"' 6
  trap '_dc::private::trap::signal::ALRM    "$LINENO" "$?" "$BASH_COMMAND"' 14
  trap '_dc::private::trap::signal::TERM    "$LINENO" "$?" "$BASH_COMMAND"' 15
  trap '_dc::private::trap::exit            "$LINENO" "$?" "$BASH_COMMAND"' EXIT
  trap '_dc::private::trap::err             "$LINENO" "$?" "$BASH_COMMAND"' ERR
}
