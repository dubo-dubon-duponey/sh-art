#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

dc-tooling::build::append(){
  local source="$1"
  local destination="$2"
  local i

  local start=""
  while IFS=$'\n' read -r i || [ "$i" ]
  do
    # Ignore file headers
    if [ "$start" ] || {
      ! printf "%s" "$i" | grep -q "^[ ]*#" && ! printf "%s" "$i" | grep -q "set -o errexit -o errtrace -o functrace -o nounset -o pipefail"
    }; then
      printf "%s\n" "$i"
      start="done"
    fi
  done < "$source" >> "$destination"
}

dc-tooling::build::header(){
  local destination="$1"
  local shortdesc="${2:-another fancy piece of shcript}"
  local license="${3:-MIT License}"
  local owner="${4-dubo-dubon-duponey}"
  local name

  name="$(basename "$1")"

  cat <<-EOF > "$destination"
#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

##########################################################################
# $name, $shortdesc
# Released under $license
# Copyright (c) $(date +"%Y") $owner
##########################################################################
EOF
}

dc-tooling::build::disable(){
  local destination="$1"
  printf "# shellcheck disable=%s\n" "$2" >> "$destination"
}

dc-tooling::build::set(){
  set -o errexit -o errtrace -o functrace -o nounset -o pipefail
}

dc-tooling::build::version(){
  dc::require git || exit

  local destination="$1"
  local source
  source="$(dirname "$2")"
  local prefix="${3:-DC}"

  # XXX --tags
  cat <<-EOF >> "$destination"
${prefix}_VERSION="$(git -C "$source" describe --match 'v[0-9]*' --dirty='.m' --always)"
${prefix}_REVISION="$(git -C "$source" rev-parse HEAD)$(if ! git -C "$source" diff --no-ext-diff --quiet --exit-code; then printf ".m\n"; fi)"
${prefix}_BUILD_DATE="$(date -R)"
${prefix}_BUILD_PLATFORM="$(uname -a)"
EOF
}
