#!/usr/bin/env bash

dc-tools::builder::append(){
  local source="$1"
  local destination="$2"
  local start
  local i

  OIFS=$IFS
  IFS=$'\n'
  while read -r i
  do
    if [ "$start" ] || ! printf "%s" "$i" | grep -q -E "^[ ]*#"; then
      printf "%s\\n" "$i"
      start="done"
    fi
  done < "$source" >> "$destination"
  IFS=$OIFS
}

dc-tools::builder::header(){
  local destination="$1"
  local shortdesc="${2:-another fancy piece of shcript}"
  local license="${3:-MIT license}"
  local owner="${4-dubo-dubon-duponey}"
  local year
  year=$(date +"%Y")

  cat <<-EOF > "$destination"
#!/usr/bin/env bash
##########################################################################
# $destination, $shortdesc
# Released under $license
# Copyright (c) $year $owner
##########################################################################
EOF
}
