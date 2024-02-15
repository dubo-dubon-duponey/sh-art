#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

##########################################################################
# Fancy stdout
# ------
# Print shit out
##########################################################################

# Output fancy shit. Used by the output module.
_dc::private::style(){
  local vName="DC_OUTPUT_$1[@]"
  local i
  for i in "${!vName}"; do
    # shellcheck disable=SC2086
    [ ! "$TERM" ] || [ ! -t 1 ] || >&1 dc::internal::securewrap tput $i 2>/dev/null || true
  done
}

# Centering is tricky to get right with unicode chars - both wc and printf will count octets...
dc::output::h1(){
  local i="$1"
  local width
  local even
  local ln

  width=$(dc::internal::securewrap tput cols 2>/dev/null || printf 60)
  ln=${#i}
  even=$(( (ln + width) & 1 ))

  printf "\n"
  printf " %.s" $(seq -s" " $(( width / 4 )))
  _dc::private::style H1_START
  printf " %.s" $(seq -s" " $(( width / 4 )))
  printf " %.s" $(seq -s" " $(( width / 4 )))
  _dc::private::style H1_END
  printf " %.s" $(seq -s" " $(( width / 4 + even )))
  printf "\n"

  printf " %.s" $(seq -s" " $(( (width - ln) / 2)))
  tr '[:lower:]' '[:upper:]' <<<"$i" 2>/dev/null || printf "%s" "$i"
  printf " %.s" $(seq -s" " $(( (width - ln) / 2)))
  printf "\n"
  printf "\n"
}

dc::output::h2(){
  local i="$1"
  local width

  width=$(dc::internal::securewrap tput cols 2>/dev/null || printf 60)

  printf "\n"
  printf "  "

  _dc::private::style H2_START
  printf "%s" "  $i"
  printf " %.s" $(seq -s" " $(( width / 2 - ${#i} - 4 )))
  _dc::private::style H2_END

  printf "\n"
  printf "\n"
}

dc::output::emphasis(){
  local i

  _dc::private::style EMPHASIS_START
  for i in "$@"; do
    printf "%s " "$i"
  done
  _dc::private::style EMPHASIS_END
}

dc::output::strong(){
  local i

  _dc::private::style STRONG_START
  for i in "$@"; do
    printf "%s " "$i"
  done
  _dc::private::style STRONG_END
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

  _dc::private::style QUOTE_START
  for i in "$@"; do
    printf "  > %s\n" "$i"
  done
  _dc::private::style QUOTE_END
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

  width=$(dc::internal::securewrap tput cols 2>/dev/null || printf 60)

  _dc::private::style RULE_START
  printf " %.s" $(seq -s" " "$width")
  _dc::private::style RULE_END
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
    || { dc::error::throw ARGUMENT_INVALID "$1" || return; }
}
