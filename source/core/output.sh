#!/usr/bin/env bash
##########################################################################
# Fancy stdout
# ------
# 1
##########################################################################

# Centering is tricky to get right with unicode chars - both wc and printf will count octets...
dc::output::h1(){
  local i="$1"

  local width
  width=$(tput cols)

  local even
  local ln

  ln=${#i}
  even=$(( (ln + width) & 1 ))

  printf "\\n"
  printf " %.s" $(seq -s" " $(( width / 4 )))
  _dc_internal::output::style H1_START
  printf " %.s" $(seq -s" " $(( width / 4 )))
  printf " %.s" $(seq -s" " $(( width / 4 )))
  _dc_internal::output::style H1_END
  printf " %.s" $(seq -s" " $(( width / 4 + even )))
  printf "\\n"

  printf " %.s" $(seq -s" " $(( (width - ln) / 2)))
  printf "%s" "$i" | tr '[:lower:]' '[:upper:]'
  printf " %.s" $(seq -s" " $(( (width - ln) / 2)))
  printf "\\n"
  printf "\\n"
}

dc::output::h2(){
  local i="$1"

  local width
  width=$(tput cols)

  printf "\\n"
  printf "  "

  _dc_internal::output::style H2_START
  printf "%s" "  $i"
  printf " %.s" $(seq -s" " $(( width / 2 - ${#i} - 4 )))
  _dc_internal::output::style H2_END

  printf "\\n"
  printf "\\n"
}

dc::output::emphasis(){
  _dc_internal::output::style EMPHASIS_START
  local i
  for i in "$@"; do
    printf "%s " "$i"
  done
  _dc_internal::output::style EMPHASIS_END
}

dc::output::strong(){
  _dc_internal::output::style STRONG_START
  local i
  for i in "$@"; do
    printf "%s " "$i"
  done
  _dc_internal::output::style STRONG_END
}

dc::output::bullet(){
  local i
  for i in "$@"; do
    printf "    • %s\\n" "$i"
  done
}

#dc::output::code(){
#}

#dc::output::table(){
#}

dc::output::quote(){
  _dc_internal::output::style QUOTE_START
  local i
  for i in "$@"; do
    printf "  > %s\\n" "$i"
  done
  _dc_internal::output::style QUOTE_END
}

dc::output::text(){
  local i
  printf "    "
  for i in "$@"; do
    printf "%s " "$i"
  done
}

dc::output::rule(){
  _dc_internal::output::style RULE_START
  local width
  width=$(tput cols)
  printf " %.s" $(seq -s" " "$width")
  _dc_internal::output::style RULE_END
}

dc::output::break(){
  printf "\\n"
}

dc::output::json() {
  dc::optional jq

  # No jq? Just echo the stuff
  if [ ! "$_DC_DEPENDENCIES_B_JQ" ]; then
    printf "%s" "$1"
    return
  fi

  # Print through jq and return on success
  if printf "%s" "$1" | jq "." 2>/dev/null; then
    return
  fi

  # Otherwise, that means the stuff was not json. Error out.
  dc::logger::error "Provided input is NOT valid json:"
  dc::logger::error "$1"
  exit "$ERROR_ARGUMENT_INVALID"
}

###############################
# Private helpers
###############################

_dc_internal::output::style(){
  local vName="DC_OUTPUT_$1[@]"
  local i
  for i in "${!vName}"; do
    # shellcheck disable=SC2086
    [ "$TERM" ] && [ -t 1 ] && >&1 tput $i
  done
}
