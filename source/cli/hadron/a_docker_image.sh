#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

#Commands:
#  build       Build an image from a Dockerfile
#  history     Show the history of an image
#  import      Import the contents from a tarball to create a filesystem image
#  inspect     Display detailed information on one or more images
#  load        Load an image from a tar archive or STDIN
#  ls          List images
#  prune       Remove unused images
#  pull        Download an image from a registry
#  push        Upload an image to a registry
#  rm          Remove one or more images
#  save        Save one or more images to a tar archive (streamed to STDOUT by default)
#  tag         Create a tag TARGET_IMAGE that refers to SOURCE_IMAGE


#Options:
#  -f, --force      Force removal of the image
#      --no-prune   Do not delete untagged parents
dc::docker::client::image::remove(){
  local com=(image remove)

  local force="${1:-}"
  [ "$force" == "" ] || com+=(--force)
  shift || true

  local no_prune="${1:-}"
  [ "$no_prune" == "" ] || com+=(--no-prune)
  shift || true

  _dc::docker::client::execute "${com[@]}" "$@"
}


#Options:
#  -a, --all-tags                Download all tagged images in the repository
#      --disable-content-trust   Skip image verification (default true)
#  -q, --quiet                   Suppress verbose output

#      --platform string         Set platform if server is multi-platform capable

dc::docker::client::image::pull(){
  local com=(image pull)

  local platform="${1:-}"
  [ "$platform" == "" ] || com+=(--platform "$platform")
  shift || true

  _dc::docker::client::execute "${com[@]}" "$@"
}

#Options:
#  -a, --all             Show all images (default hides intermediate images)
#      --digests         Show digests
#  -f, --filter filter   Filter output based on conditions provided
#      --format string   Format output using a custom template:
#                        'table':            Print output in table format with column headers (default)
#                        'table TEMPLATE':   Print output in table format using the given Go template
#                        'json':             Print in JSON format
#                        'TEMPLATE':         Print output using the given Go template.
#                        Refer to https://docs.docker.com/go/formatting/ for more information about formatting output with templates
#      --no-trunc        Don't truncate output
#  -q, --quiet           Only show image IDs

dc::docker::client::image::list(){
  local com=(image list)

  local all="${1:-}"
  [ "$all" == "" ] || com+=(--all)
  shift || true

  local format="${1:-}"
  [ "$format" == "" ] || com+=(--format "$format")
  shift || true

  local filter="${1:-}"
  [ "$filter" == "" ] || com+=(--filter "$filter")
  shift || true

  _dc::docker::client::execute "${com[@]}" "$@"
}


dc::docker::client::image::inspect() {
  local com=(image inspect)

  local format="${1:-}"
  [ "$format" == "" ] || com+=(--format "$format")
  shift || true

  _dc::docker::client::execute "${com[@]}" "$@"
}


#  -a, --all             Remove all unused images, not just dangling ones
#      --filter filter   Provide filter values (e.g. "until=<timestamp>")
#  -f, --force           Do not prompt for confirmation
dc::docker::client::image::prune(){
  local com=(image prune)

  local all="${1:-}"
  [ "$all" == "" ] || com+=(--all)
  shift || true

  local filter="${1:-}"
  [ "$filter" == "" ] || com+=(--filter "$filter")
  shift || true

  local force="${1:-}"
  [ "$force" == "" ] || com+=(--force)
  shift || true

  _dc::docker::client::execute "${com[@]}" "$@"
}
