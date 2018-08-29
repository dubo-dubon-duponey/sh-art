#!/usr/bin/env bash

dc-tools::builder::append(){
  local source="$1"
  local destination="$2"

  OIFS=$IFS
  IFS=$'\n'
  cat "$source" | \
    while read i
    do
      # Ignore lines starting with #
      iscomment=$(echo "$i" | grep -E "^[ ]*#" )
      if [ "$iscomment" ]; then
        continue
      fi
      echo "$i"
    done >> "$destination"
  IFS=$OIFS
}

dc-tools::builder::header(){
  local destination="$1"
  local shortdesc="${2:-another fancy piece of shcript}"
  local license="${3:-MIT license}"
  local owner="${4-dubo-dubon-duponey}"
  local year=$(date +"%Y")

  cat <<-EOF > "$destination"
#!/usr/bin/env bash
##########################################################################
# $destination, $shortdesc
# Released under $license
# Copyright (c) $year $owner
##########################################################################
EOF
}
