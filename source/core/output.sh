#!/usr/bin/env bash
##########################################################################
# Fancy stdout
# ------
# 1
##########################################################################

export DC_STYLE_H1_START=( bold smul "setaf $DC_COLOR_WHITE" )
export DC_STYLE_H1_END=( sgr0 rmul op )

export DC_STYLE_H2_START=( bold smul "setaf $DC_COLOR_WHITE" )
export DC_STYLE_H2_END=( sgr0 rmul op )

export DC_STYLE_EMPHASIS_START=bold
export DC_STYLE_EMPHASIS_END=sgr0

export DC_STYLE_STRONG_START=( bold "setaf $DC_COLOR_RED" )
export DC_STYLE_STRONG_END=( sgr0 op )

export DC_STYLE_RULE_START=( bold smul )
export DC_STYLE_RULE_END=( sgr0 rmul )

export DC_STYLE_QUOTE_START=bold
export DC_STYLE_QUOTE_END=sgr0

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
  _dc::style H1_START
  printf " %.s" $(seq -s" " $(( width / 4 )))
  printf " %.s" $(seq -s" " $(( width / 4 )))
  _dc::style H1_END
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

  _dc::style H2_START
  printf "%s" "  $i"
  printf " %.s" $(seq -s" " $(( width / 2 - ${#i} - 4 )))
  _dc::style H2_END

  printf "\\n"
  printf "\\n"
}

dc::output::emphasis(){
  _dc::style EMPHASIS_START
  local i
  for i in "$@"; do
    printf "%s " "$i"
  done
  _dc::style EMPHASIS_END
}

dc::output::strong(){
  _dc::style STRONG_START
  local i
  for i in "$@"; do
    printf "%s " "$i"
  done
  _dc::style STRONG_END
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
  _dc::style QUOTE_START
  local i
  for i in "$@"; do
    printf "  > %s\\n" "$i"
  done
  _dc::style QUOTE_END
}

dc::output::text(){
  local i
  printf "    "
  for i in "$@"; do
    printf "%s " "$i"
  done
}

dc::output::rule(){
  _dc::style RULE_START
  local width
  width=$(tput cols)
  printf " %.s" $(seq -s" " "$width")
  _dc::style RULE_END
}

dc::output::break(){
  printf "\\n"
}

dc::output::json() {
  dc::optional "$_DC_OUTPUT_JSON_JQ"

  # Print through jq and return
  if printf "%s" "$1" | "$_DC_OUTPUT_JSON_JQ" "." 2>/dev/null; then
    return
  fi

  # Failed... do we have jq? If not, just echo the stuff and pray
  if [ ! "$_DC_DEPENDENCIES_B_JQ" ]; then
    printf "%s" "$1"
    return
  fi

  # Otherwise, that means the stuff was not json. Error out.
  dc::logger::error "Provided input is NOT valid json:"
  dc::logger::error "$1"
  exit "$ERROR_ARGUMENT_INVALID"
}

#
# Private helpers
#
# Private hook to ease testing
_DC_OUTPUT_JSON_JQ=jq

_dc::style(){
  local vName="DC_STYLE_$1[@]"
  local i
  for i in "${!vName}"; do
    [ "$TERM" ] && [ -t 1 ] && >&1 tput "$i"
  done
}
