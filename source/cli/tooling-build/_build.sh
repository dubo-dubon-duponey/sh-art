#!/usr/bin/env bash

dc-tools::build::append(){
  local source="$1"
  local destination="$2"

  OIFS=$IFS
  IFS=$'\n'
  while read -r i
  do
    # Ignore lines starting with #
    if printf "%s" "$i" | grep -q -E "^[ ]*#"; then
      continue
    fi
    printf "%s\\n" "$i"
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
