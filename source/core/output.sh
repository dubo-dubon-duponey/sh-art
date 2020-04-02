#!/usr/bin/env bash
##########################################################################
# Fancy stdout
# ------
# Print shit out
##########################################################################

# Output fancy shit. Used by the output module.
dc::internal::style(){
  local vName="DC_OUTPUT_$1[@]"
  local i
  for i in "${!vName}"; do
    # shellcheck disable=SC2086
    [ "$TERM" ] && [ -t 1 ] && >&1 tput $i
  done
}

# Centering is tricky to get right with unicode chars - both wc and printf will count octets...
dc::output::h1(){
  local i="$1"
  local width
  local even
  local ln

  width=$(tput cols)
  ln=${#i}
  even=$(( (ln + width) & 1 ))

  printf "\n"
  printf " %.s" $(seq -s" " $(( width / 4 )))
  dc::internal::style H1_START
  printf " %.s" $(seq -s" " $(( width / 4 )))
  printf " %.s" $(seq -s" " $(( width / 4 )))
  dc::internal::style H1_END
  printf " %.s" $(seq -s" " $(( width / 4 + even )))
  printf "\n"

  printf " %.s" $(seq -s" " $(( (width - ln) / 2)))
  printf "%s" "$i" | tr '[:lower:]' '[:upper:]'
  printf " %.s" $(seq -s" " $(( (width - ln) / 2)))
  printf "\n"
  printf "\n"
}

dc::output::h2(){
  local i="$1"
  local width

  width=$(tput cols)

  printf "\n"
  printf "  "

  dc::internal::style H2_START
  printf "%s" "  $i"
  printf " %.s" $(seq -s" " $(( width / 2 - ${#i} - 4 )))
  dc::internal::style H2_END

  printf "\n"
  printf "\n"
}

dc::output::emphasis(){
  local i

  dc::internal::style EMPHASIS_START
  for i in "$@"; do
    printf "%s " "$i"
  done
  dc::internal::style EMPHASIS_END
}

dc::output::strong(){
  local i

  dc::internal::style STRONG_START
  for i in "$@"; do
    printf "%s " "$i"
  done
  dc::internal::style STRONG_END
}

dc::output::bullet(){
  local i

  for i in "$@"; do
    printf "    • %s\n" "$i"
  done
}

#dc::output::code(){
#}

#dc::output::table(){
#}

dc::output::quote(){
  local i

  dc::internal::style QUOTE_START
  for i in "$@"; do
    printf "  > %s\n" "$i"
  done
  dc::internal::style QUOTE_END
}

dc::output::text(){
  local i

  printf "    "
  for i in "$@"; do
    printf "%s " "$i"
  done
}

dc::output::rule(){
  local width

  dc::argument::check width "$DC_TYPE_INTEGER" || return

  width=$(tput cols)
  dc::internal::style RULE_START
  printf " %.s" $(seq -s" " "$width")
  dc::internal::style RULE_END
}

dc::output::break(){
  printf "\n"
}

dc::output::json() {
  # No jq? Just echo the stuff
  if ! dc::require jq; then
    printf "%s" "$1"
    return
  fi

  # Otherwise, print through jq and return on success
  printf "%s" "$1" | jq "." 2>/dev/null \
    || { dc::error::detail::set "$1" && return "$ERROR_ARGUMENT_INVALID"; }
}
