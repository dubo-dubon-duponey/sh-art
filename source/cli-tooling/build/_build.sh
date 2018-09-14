#!/usr/bin/env bash

dc-tools::build::append(){
  local source="$1"
  local destination="$2"

  OIFS=$IFS
  IFS=$'\n'
  local start
  while read -r i
  do
    # Ignore file headers
    if [ "$start" ] || ! printf "%s" "$i" | grep -q -E "^[ ]*#"; then
      printf "%s\\n" "$i"
      start="done"
    fi
  done < "$source" >> "$destination"
  IFS=$OIFS
}

dc-tools::build::header(){
  local destination="$1"
  local shortdesc="${2:-another fancy piece of shcript}"
  local license="${3:-MIT license}"
  local owner="${4-dubo-dubon-duponey}"
  local name
  name="$(basename "$1")"

  cat <<-EOF > "$destination"
#!/usr/bin/env bash
##########################################################################
# $name, $shortdesc
# Released under $license
# Copyright (c) $(date +"%Y") $owner
##########################################################################
EOF
}

dc-tools::build::version(){
  local destination="$1"
  cat <<-EOF >> "$destination"
DC_VERSION="$(git describe --match 'v[0-9]*' --dirty='.m' --always)"
DC_REVISION="$(git rev-parse HEAD)$(if ! git diff --no-ext-diff --quiet --exit-code; then echo ".m"; fi)"
DC_BUILD_DATE="$(date -R)"
EOF
}
