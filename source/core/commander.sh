#!/usr/bin/env bash
##########################################################################
# Command-line helpers
# ------
# These methods provide sane defaults for command-line applications
# Implementers should simply call dc::commander::init (see description for details)
# For more control, you can override dc::commander::help or dc::commander::version by redefining the function,
# or even rewrite your own initialization method
##########################################################################

readonly DC_CLI_NAME=$(basename "$0")
readonly DC_CLI_VERSION="$DC_VERSION (core script)"
readonly DC_CLI_LICENSE="MIT license"
readonly DC_CLI_DESC="A fancy piece of shcript"
export DC_CLI_USAGE=""
export DC_CLI_OPTS=()

# The method being called when the "help" flag is used (by default --help or -h) is passed to the script
# Override this method in your script to define your own help
dc::commander::help(){
  local name="$1"
  local version="$2"
  local license="$3"
  local shortdesc="$4"
  local shortusage="$5"
  local long="$6"

  dc::output::h1 "$name"
  dc::output::quote "$shortdesc"

  dc::output::h2 "Version"
  dc::output::text "$version"
  dc::output::break

  dc::output::h2 "License"
  dc::output::text "$license"
  dc::output::break

  dc::output::h2 "Usage"
  dc::output::text "$name --help"
  dc::output::break
  dc::output::text "$name --version"
  dc::output::break
  dc::output::break
  dc::output::text "$name $shortusage"
  dc::output::break
  if [ "$long" ]; then
    dc::output::h2 "Options"
    local v
    while read -r v; do
      dc::output::bullet "$v"
    done < <(printf "%s" "$long")
  fi

  dc::output::h2 "Logging control"
  dc::output::bullet "$(printf "%s" "${CLI_NAME:-${DC_CLI_NAME}}" | tr "-" "_" | tr "[:lower:]" "[:upper:]")_LOG_LEVEL=(debug|info|warning|error) will adjust logging level (default to info)"
  dc::output::bullet "$(printf "%s" "${CLI_NAME:-${DC_CLI_NAME}}" | tr "-" "_" | tr "[:lower:]" "[:upper:]")_LOG_AUTH=true will also log sensitive/credentials information (CAREFUL)"
  dc::output::break

}

# The method being called when the "version" flag is used (by default --version or -v) is passed to the script
# Override this method in your script to define your own version output
dc::commander::version(){
  printf "%s %s\\n" "$1" "$2"
}


dc::commander::declare::arg(){
  local number="$1"
  local validator="$2"
  local optional="$3"
  local fancy="$4"
  local description="$5"
  local gf="${6:--Ei}"

  local var="DC_PARGV_$number"
  local varexist="DC_PARGE_$number"

  if [ "${DC_CLI_USAGE}" ]; then
    fancy=" $fancy"
  fi

  local long="$fancy"
  long=$(printf "%-20s" "$long")
  if [ "$optional" ]; then
    long="$long (optional)"
  else
    long="$long            "
  fi

  DC_CLI_USAGE="${DC_CLI_USAGE}$fancy"
  DC_CLI_OPTS+=( "$long $description" )

  # If nothing was specified
  if [ ! "${!varexist}" ]; then
    # Was optional? Then just return.
    if [ "$optional" ]; then
      return
    fi
    # Asking for help or version, drop it as well
    if [ "${DC_ARGE_HELP}" ] || [ "${DC_ARGE_H}" ] || [ "${DC_ARGE_VERSION}" ]; then
      return
    fi
    # Otherwise, yeah, genuine error
    dc::logger::error "You must specify argument $1."
    exit "$ERROR_ARGUMENT_MISSING"
  fi

  if [ "$validator" ]; then
    if printf "%s" "${!var}" | grep -q "$gf" "$validator"; then
      return
    fi
    dc::logger::error "Argument \"$1\" is invalid. Must match \"$validator\". Value is: \"${!var}\"."
    exit "$ERROR_ARGUMENT_INVALID"
  fi
}

dc::commander::declare::flag(){
  local name="$1"
  local validator="$2"
  local optional="$3"
  local description="$4"
  local alias="$5"
  local gf="${6:--Ei}"

  local display="--$name"
  local long="--$name"
  if [ "$alias" ]; then
    display="$display/-$alias"
    long="$long, -$alias"
  fi
  if [ "$validator" ]; then
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
  if [ "${DC_CLI_USAGE}" ]; then
    display=" $display"
  fi

  DC_CLI_USAGE="${DC_CLI_USAGE}$display"
  # XXX add padding
  DC_CLI_OPTS+=( "$long $description" )

  local m
  local mv
  m="DC_ARGE_$(printf "%s" "$name" | tr "-" "_" | tr '[:lower:]' '[:upper:]')"
  mv="DC_ARGV_$(printf "%s" "$name" | tr "-" "_" | tr '[:lower:]' '[:upper:]')"

  local s
  local sv

  if [ "$alias" ]; then
    s="DC_ARGE_$(printf "%s" "$alias" | tr '[:lower:]' '[:upper:]')"
    sv="DC_ARGV_$(printf "%s" "$alias" | tr '[:lower:]' '[:upper:]')"

    if [ "${!m}" ] && [ "${!s}" ]; then
      dc::logger::error "You cannot specify $name and $alias at the same time"
      exit "$ERROR_ARGUMENT_INVALID"
    fi
  fi

  # If nothing was specified
  if [ ! "${!m}" ] && [ ! "${!s}" ]; then
    # Was optional? Then just return.
    if [ "$optional" ]; then
      return
    fi
    # Asking for help or version, drop it as well
    if [ "${DC_ARGE_HELP}" ] || [ "${DC_ARGE_H}" ] || [ "${DC_ARGE_VERSION}" ]; then
      return
    fi
    # Otherwise, yeah, genuine error
    dc::logger::error "The flag $name must be specified."
    exit "$ERROR_ARGUMENT_MISSING"
  fi

  # We know at this point the values are not null, validate then
  if [ "$validator" ]; then
    if printf "%s" "${!mv}" | grep -q "$gf" "$validator"; then
      return
    fi
    if printf "%s" "${!sv}" | grep -q "$gf" "$validator"; then
      return
    fi
    dc::logger::error "Flag \"$(printf "%s" "$1" | tr "_" "-" | tr '[:upper:]' '[:lower:]')\" is invalid. Must match \"$validator\". Value is: \"${!var}\"."
    exit "$ERROR_ARGUMENT_INVALID"
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

dc::commander::initialize(){
  dc::commander::declare::flag "silent" "" "optional" "silence all logging (overrides log level)" "s"
  dc::commander::declare::flag "insecure" "" "optional" "disable TLS verification for network operations"

  local loglevelvar
  local logauthvar
  loglevelvar="$(printf "%s" "${CLI_NAME:-${DC_CLI_NAME}}" | tr "-" "_" | tr "[:lower:]" "[:upper:]")_LOG_LEVEL"
  logauthvar="$(printf "%s" "${CLI_NAME:-${DC_CLI_NAME}}" | tr "-" "_" | tr "[:lower:]" "[:upper:]")_LOG_AUTH"

  [ ! "${1+x}" ] || loglevelvar="$1"
  [ ! "${2+x}" ] || logauthvar="$2"

  # If the "-s" flag is passed, mute the logger entirely
  if [ -n "${DC_ARGV_SILENT+x}" ] || [ -n "${DC_ARGV_S+x}" ]; then
    dc::configure::logger::mute
  else
    # Configure the logger from the LOG_LEVEL env variable
    case "$(printf "%s" "${!loglevelvar}" | tr '[:lower:]' '[:upper:]')" in
      DEBUG)
        dc::configure::logger::setlevel::debug
      ;;
      INFO)
        dc::configure::logger::setlevel::info
      ;;
      WARNING)
        dc::configure::logger::setlevel::warning
      ;;
      ERROR)
        dc::configure::logger::setlevel::error
      ;;
    esac
  fi

  # If the LOG_AUTH env variable is set, honor it and leak!
  if [ "${!logauthvar}" ]; then
    dc::configure::http::leak
  fi

  # If the --insecure flag is passed, allow insecure TLS connections
  if [ "${DC_ARGV_INSECURE+x}" ]; then
    dc::configure::http::insecure
  fi
}

dc::commander::boot(){
  # If we have been asked for --help or -h, show help
  if [ "${DC_ARGE_HELP}" ] || [ "${DC_ARGE_H}" ]; then

    local opts=
    local i
    for i in "${DC_CLI_OPTS[@]}"; do
      opts="$opts$i"$'\n'
    done

    dc::commander::help \
      "${CLI_NAME:-${DC_CLI_NAME}}" \
      "${CLI_VERSION:-${DC_CLI_VERSION}}" \
      "${CLI_LICENSE:-${DC_CLI_LICENSE}}" \
      "${CLI_DESC:-${DC_CLI_DESC}}" \
      "${CLI_USAGE:-${DC_CLI_USAGE}}" \
      "${CLI_OPTS:-$opts}"
    exit
  fi

  # If we have been asked for --version, show the version
  if [ "${DC_ARGE_VERSION}" ]; then
    dc::commander::version "${CLI_NAME:-${DC_CLI_NAME}}" "${CLI_VERSION:-${DC_CLI_VERSION}}"
    exit
  fi

}
