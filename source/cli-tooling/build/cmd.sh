#!/usr/bin/env bash
## Builder
readonly CLI_DESC="a lightweight script builder"

dc::commander::initialize
# Need a non-null name
dc::commander::declare::flag name ".+" "" "Name of the script to be produced"
dc::commander::declare::flag destination ".+" optional "Output directory. Default to ./bin if left unspecified"
dc::commander::declare::flag author ".+" optional "Name of the author"
dc::commander::declare::flag license ".+" optional "Script final license. MIT if unspecified"
dc::commander::declare::flag description ".+" optional "A short project description to be added to the license header"
dc::commander::declare::flag with-git-info "" optional "Will prepend DC_VERSION, DC_REVISION and DC_BUILD_DATE variables"
dc::commander::declare::arg 1 ".+" "" "source [...source]" "Source file (or directory) to use to generate the final script. Add as many as required. If specifying a directory, *.sh files will be used (not recursive)"
# Start commander
dc::commander::boot

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
  dc-tools::build::version "$destination" "$DC_PARGV_1"
fi

# XXX somewhat cavalier
for item in "$@"; do
  if [ "${item:0:1}" == "-" ]; then
    continue
  fi
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
