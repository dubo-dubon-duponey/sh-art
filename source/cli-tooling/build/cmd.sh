#!/usr/bin/env bash

true

# shellcheck disable=SC2034
readonly CLI_DESC="a lightweight script builder"

dc::commander::initialize
# Need a non-null name
dc::commander::declare::flag name "$DC_TYPE_STRING" "Name of the script to be produced"
dc::commander::declare::flag destination "$DC_TYPE_STRING" "Output directory. Default to ./bin if left unspecified" optional
dc::commander::declare::flag author "$DC_TYPE_STRING" "Name of the author" optional
dc::commander::declare::flag license "$DC_TYPE_STRING" "Script final license. MIT if unspecified" optional
dc::commander::declare::flag description "$DC_TYPE_STRING" "A short project description to be added to the license header" optional
dc::commander::declare::flag shellcheck-disable "$DC_TYPE_STRING" "Will add shellcheck disable headers to the script" optional
dc::commander::declare::flag with-git-info "" "Will prepend DC_VERSION, DC_REVISION and DC_BUILD_DATE variables" optional
dc::commander::declare::arg 1 "$DC_TYPE_STRING" "source [...source]" "Source file (or directory) to use to generate the final script. Add as many as required. If specifying a directory, *.sh files will be used (not recursive)"
# Start commander
dc::commander::boot

# If we have an explicit destination, use that, otherwise, fallback to cwd/bin
destination="${DC_ARG_DESTINATION:-./bin}"

# By all means, destination must be a writable directory - create if needed
dc::fs::isdir "$destination" writable create

# Set the final destination
destination="$destination/$DC_ARG_NAME"

# Pack in the header to the final destination
dc-tooling::build::header "$destination" "${DC_ARG_DESCRIPTION:-another fancy piece of shcript}" "${DC_ARG_LICENSE:-MIT License}" "${DC_ARG_AUTHOR:-dubo-dubon-duponey}"

# Add git information
# Always use the last argument as git information source (first arg may be a library out of the tree)
! dc::args::exist shellcheck-disable || dc-tooling::build::disable "$destination" "$DC_ARG_SHELLCHECK_DISABLE"
! dc::args::exist with-git-info || dc-tooling::build::version "$destination" "${@: -1}" "$DC_ARG_WITH_GIT_INFO"

# XXX somewhat cavalier
for item in "$@"; do
  [ "${item:0:1}" != "-" ] || continue
  if dc::fs::isfile "$item"; then
    dc-tooling::build::append "$item" "$destination"
    continue
  fi
  dc::fs::isdir "$item"
  for k in "$item/"*.sh; do
    dc-tooling::build::append "$k" "$destination"
  done
done

chmod u+x "$destination"
