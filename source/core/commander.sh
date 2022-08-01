#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

##########################################################################
# Command-line helpers
# ------
# These methods provide sane defaults for command-line applications
# Implementers should simply call dc::commander::init (see description for details)
# For more control, you can override dc::commander::help or dc::commander::version by redefining the function,
# or even rewrite your own initialization method
##########################################################################

export _DC_INTERNAL_CLI_USAGE=""
export _DC_INTERNAL_CLI_OPTS=()

dc::commander::requirements(){
  # Can't really do anything without this
  # Note: we would have failed before if it was not there
  # dc::require printf || return

  # We have to use this in a number of occasions (bash 3), and of course for prompting, etc
  dc::require read || return

  dc::require jq || {
    dc::logger::warning "You are missing the jq binary. JSON formatting and validation will be non-existent."
  }

  dc::require tput || {
    dc::logger::warning "You are missing the tput binary. No fancy formatting for you."
  }

  dc::require date || {
    dc::logger::warning "You are missing the date binary. No date in logs for you."
  }

  dc::require sed || {
    dc::logger::warning "You are missing the sed binary. At the very least, dependencies version detection will be broken."
  }

  dc::require tr || {
    dc::logger::warning "You are missing the tr binary. Some operations involving variable manipulation will fail in subtle and confusing ways."
  }

  dc::require curl || {
    dc::logger::warning "You are missing the curl binary. Network operations will not work."
  }

  # shellcheck disable=SC2015
  dc::require rm && dc::require mktemp && dc::require mkdir && dc::require touch || {
    dc::logger::warning "You are missing mktemp or mkdir or touch. FS operations will fail with a lot of drama."
  }
}

dc::commander::trap(){
  # Set up the traps
  dc::trap::setup
}

# The method being called when the "help" flag is used (by default --help or -h) is passed to the script
# Override this method in your script to define your own help
dc::commander::help(){
  local name="$1"
  local license="$2"
  local shortdesc="$3"
  local shortusage="$4"
  local long="$5"
  local examples="$6"

  dc::output::h1 "$name"
  dc::output::quote "$shortdesc"

  dc::output::h2 "Usage"
  dc::output::text "$name $shortusage"
  dc::output::break
  dc::output::break
  dc::output::text "$name --help"
  dc::output::break
  dc::output::text "$name --version"
  dc::output::break

  # XXX annoying that -s and --insecure are first - fix it
  if [ "$long" ]; then
    dc::output::h2 "Arguments"
    local v
    while IFS= read -r v || [ "$v" ]; do
      [ ! "$v" ] || dc::output::bullet "$v"
    done <<< "$long"
    dc::output::break
  fi

  dc::output::h2 "Logging control"
  dc::output::bullet "$(dc::internal::varnorm "$name")_LOG_LEVEL=(debug|info|warning|error) will adjust logging level (default to info)"
  dc::output::bullet "$(dc::internal::varnorm "$name")_LOG_AUTH=true will also log sensitive/credentials information (CAREFUL)"

# This is visible through the --version flag anyway...
#  dc::output::h2 "Version"
#  dc::output::text "$version"
#  dc::output::break

  if [ "$examples" ]; then
    dc::output::h2 "Examples"
    local v
    while IFS= read -r v || [ "$v" ]; do
      if [ "${v:0:1}" == ">" ]; then
        printf "    %s\n" "$v"
      elif [ "$v" ]; then
        dc::output::bullet "$v"
      else
        dc::output::break
      fi
    done <<< "$examples"
    dc::output::break
  fi

  dc::output::h2 "License"
  dc::output::text "$license"
  dc::output::break
  dc::output::break

}

# The method being called when the "version" flag is used (by default --version or -v) is passed to the script
# Override this method in your script to define your own version output
dc::commander::version(){
  printf "%s %s\n" "$1" "$2"
}


dc::commander::declare::arg(){
  local number="$1"
  local validator="$2"
  local fancy="$3"
  local description="$4"
  local optional="${5:-}"

  local long="$fancy"
  long=$(printf "%-20s" "$long")
  if [ "$optional" ]; then
    fancy="[$fancy]"
    long="$long (optional)"
  else
    long="$long           "
  fi

  #if [ "${_DC_INTERNAL_CLI_USAGE}" ]; then
  #  fancy=" $fancy"
  #fi

  _DC_INTERNAL_CLI_USAGE="${_DC_INTERNAL_CLI_USAGE}$fancy "
  _DC_INTERNAL_CLI_OPTS+=( "$long $description" )

  # Asking for help or version, do not validate
  if dc::args::exist "help" || dc::args::exist "h" || dc::args::exist "version"; then
    return
  fi

  # Otherwise, validate
  dc::args::validate "$number" "$validator" "$optional" || return
}

dc::commander::declare::flag(){
  local name="$1"
  local validator="$2"
  local description="$3"
  local optional="${4:-}"
  local alias="${5:-}"

  local display="--$name"
  local long="--$name"
  if [ "$alias" ]; then
    display="$display/-$alias"
    long="$long, -$alias"
  fi
  if [ "$validator" ] && [ "$validator" != "^$" ]; then
    display="$display=$validator"
    long="$long=value"
  fi
  long=$(printf "%-20s" "$long")
  if [ "$optional" ]; then
    display="[$display]"
    long="$long (optional)"
  else
    long="$long           "
  fi
  # if [ "${_DC_INTERNAL_CLI_USAGE}" ]; then
  #  display=" $display"
  # fi

  _DC_INTERNAL_CLI_USAGE="${_DC_INTERNAL_CLI_USAGE}$display "
  # XXX add padding
  _DC_INTERNAL_CLI_OPTS+=( "$long $description" )

  # Asking for help or version, do not validate
  if dc::args::exist "help" || dc::args::exist "h" || dc::args::exist "version"; then
    return
  fi

  # Validate the alias or the main one
  if [ "$(dc::args::exist "$alias")" ]; then
    # First make sure we do not have a double dip
    if [ "$(dc::args::exist "$name")" ]; then
      dc::logger::error "You cannot specify $name and $alias at the same time"
      return "$ERROR_ARGUMENT_INVALID"
    fi
    # Ok? Validate the alias
    dc::args::validate "$alias" "$validator" "$optional" || return
  else
    # Otherwise, the main arg
    dc::args::validate "$name" "$validator" "$optional" || return
  fi
}

# This is the entrypoint you should call in your script
# It will take care of hooking the --help/-h and --version flags, and configure logging according to
# environment variables (by default LOG_LEVEL and LOG_AUTH).
# It will honor the "--insecure" flag to ignore TLS errors
# It will honor the "-s/--silent" flag to silent any output to stderr
# You should define CLI_VERSION, CLI_LICENSE, CLI_DESC and CLI_USAGE before calling init
# You may define CLI_NAME if you want your name to be different from the script name (not recommended)
# This method will use the *CLI_NAME*_LOG_LEVEL (debug, info, warning, error) environment variable to set the logger
# If you want a different environment variable to be used, pass its name as the first argument
# The same goes for the *CLI_NAME*_LOG_AUTH environment variable

# shellcheck disable=SC2120
dc::commander::initialize(){
  # Enfore basic requirements and some
  dc::commander::requirements
  # Trap signals
  dc::commander::trap
  # Attach the default error handler
  dc::trap::register dc::error::handler

  dc::commander::declare::flag "silent" "^$" "no logging (overrides log level)" optional "s"

  local loglevelvar
  local logauthvar
  local level
  loglevelvar="$(dc::internal::varnorm "${CLI_NAME:-${DC_DEFAULT_CLI_NAME}}")_LOG_LEVEL"
  logauthvar="$(dc::internal::varnorm "${CLI_NAME:-${DC_DEFAULT_CLI_NAME}}")_LOG_AUTH"

  [ ! "${1:-}" ] || loglevelvar="$1"
  [ ! "${2:-}" ] || logauthvar="$2"

  # If we have a log level, set it
  if [ "${!loglevelvar:-}" ]; then
    # Configure the logger from the LOG_LEVEL env variable
    level="$(printf "DC_LOGGER_%s" "${!loglevelvar}" | tr '[:lower:]' '[:upper:]')"
    dc::logger::level::set "${!level}"
  fi

  # If the LOG_AUTH env variable is set, honor it and leak
  if [ "${!logauthvar:-}" ]; then
    dc::http::leak::set
  fi

  # If the "-s" flag is passed, mute the logger entirely
  if dc::args::exist silent || dc::args::exist s; then
    dc::logger::mute
  fi

  # If the --insecure flag is passed, allow insecure TLS connections
  ! dc::args::exist insecure || dc::http::insecure::set
}

dc::commander::boot(){
  # If we have been asked for --help or -h, show help
  if dc::args::exist help || dc::args::exist h; then

    local opts=
    local i
    for i in "${_DC_INTERNAL_CLI_OPTS[@]}"; do
      opts="$opts$i"$'\n'
    done

    dc::commander::help \
      "${CLI_NAME:-${DC_DEFAULT_CLI_NAME}}" \
      "${CLI_LICENSE:-${DC_DEFAULT_CLI_LICENSE}}" \
      "${CLI_DESC:-${DC_DEFAULT_CLI_DESC}}" \
      "${CLI_USAGE:-${_DC_INTERNAL_CLI_USAGE}}" \
      "${CLI_OPTS:-$opts}" \
      "${CLI_EXAMPLES:-}"
    exit
  fi

  # If we have been asked for --version, show the version
  if dc::args::exist version; then
    dc::commander::version "${CLI_NAME:-${DC_DEFAULT_CLI_NAME}}" "${CLI_VERSION:-${DC_DEFAULT_CLI_VERSION}}"
    exit
  fi
}
