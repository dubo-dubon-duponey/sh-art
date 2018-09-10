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

  cat <<-EOF > "$destination"
#!/usr/bin/env bash
##########################################################################
# $destination, $shortdesc
# Released under $license
# Copyright (c) $(date +"%Y") $owner
##########################################################################
EOF
}
