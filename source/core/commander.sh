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
readonly DC_CLI_VERSION=unknown
readonly DC_CLI_LICENSE="MIT license"
readonly DC_CLI_DESC="A fancy piece of shcript"
readonly DC_CLI_USAGE="$DC_CLI_NAME [flags] argument"

# The method being called when the "help" flag is used (by default --help or -h) is passed to the script
# Override this method in your script to define your own help
dc::commander::help(){
  local name=$1
  local version=$2
  local license=$3
  local shortdesc=$4
  local shortusage=$5
  printf "%s, version %s, released under %s\\n" "$name" "$version" "$license"
  printf "\\t> %s\\n" "$shortdesc"
  printf "\\n"
  printf "Usage\\n"
  printf "\\t> %s %s\\n" "$name" "$shortusage"
}

# The method being called when the "version" flag is used (by default --version or -v) is passed to the script
# Override this method in your script to define your own version output
dc::commander::version(){
  local name=$1
  local version=$2
  printf "%s %s\\n" "$name" "$version"
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

dc::commander::init(){
  local defaultllv
  local defaultlav
  local loglevelvar
  local logauthvar
  defaultllv="$(echo "${CLI_NAME:-${DC_CLI_NAME}}" | tr "-" "_" | tr "[:lower:]" "[:upper:]")_LOG_LEVEL"
  loglevelvar="${1:-${defaultllv}}"
  defaultlav="$(echo "${CLI_NAME:-${DC_CLI_NAME}}" | tr "-" "_" | tr "[:lower:]" "[:upper:]")_LOG_AUTH"
  logauthvar="${2:-${defaultlav}}"

  # If we have been asked for --help or -h, show help
  if [ -n "${DC_ARGV_HELP+x}" ] || [ -n "${DC_ARGV_H+x}" ]; then
    dc::commander::help \
      "${CLI_NAME:-${DC_CLI_NAME}}" \
      "${CLI_VERSION:-${DC_CLI_VERSION}}" \
      "${CLI_LICENSE:-${DC_CLI_LICENSE}}" \
      "${CLI_DESC:-${DC_CLI_DESC}}" \
      "${CLI_USAGE:-${DC_CLI_USAGE}}"
    exit
  fi

  # If we have been asked for --version, show the version
  if [ -n "${DC_ARGV_VERSION+x}" ]; then
    dc::commander::version "${CLI_NAME:-${DC_CLI_NAME}}" "${CLI_VERSION:-${DC_CLI_VERSION}}"
    exit
  fi

  # If the "-s" flag is passed, mute the logger entirely
  if [ -n "${DC_ARGV_SILENT+x}" ] || [ -n "${DC_ARGV_S+x}" ]; then
    dc::configure::logger::mute
  else
    # Configure the logger from the LOG_LEVEL env variable
    case "$(echo "${!loglevelvar}" | tr '[:lower:]' '[:upper:]')" in
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
