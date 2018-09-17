#!/usr/bin/env bash
## Builder
readonly CLI_VERSION="0.0.1"
readonly CLI_LICENSE="MIT License"
readonly CLI_DESC="script builder & runner (part of the dc-tooling suite)"
readonly CLI_USAGE="[-s] --name=foo [--destination=.] [--license=MIT license] [--author=dubo-dubon-duponey] [--with-git-info] [--description=another fancy piece of shcript] file_or_directory [...file_or_directory]"

dc::commander::init

# Need git
dc::require::git

# Need a non-null name
dc::argv::flag::validate name ".+"

# Need at least one source
dc::argv::arg::validate 1 ".+"

# If we have an explicit destination, use that, otherwise, fallback to cwd/bin
destination="${DC_ARGV_DESTINATION:-./bin}"

# By all means, destination must be a writable directory - create if needed
dc::fs::isdir "$destination" writable create

# Set the final destination
destination="$destination/$DC_ARGV_NAME"

# Pack in the header to the final destination
dc-tools::build::header "$destination" "${DC_ARGV_DESCRIPTION:-another fancy piece of shcript}" "${DC_ARGV_LICENSE:-MIT License}" "${DC_ARGV_AUTHOR:-dubo-dubon-duponey}"

# Add git information
if [ "$DC_ARGE_WITH_GIT_INFO" ]; then
  dc-tools::build::version "$destination" "$1"
fi

for item in "$@"; do
  if [ ! -r "$item" ]; then
    dc::logger::error "$item cannot be read"
    exit "$ERROR_ARGUMENT_INVALID"
  fi
  if [ -f "$item" ]; then
    dc-tools::build::append "$item" "$destination"
    continue
  fi
  for k in "$item/"*.sh; do
    dc-tools::build::append "$k" "$destination"
  done
done

chmod u+x "$destination"
