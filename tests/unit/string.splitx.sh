#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

. source/lib/string.sh

#### splitN

##########################################
# Null haystack and null sep
##########################################
testSplitNNullHaystackAndNullSep(){
  local haystack=
  local sep=
  local count
  local result

  local count=0
  local result=()
  while IFS= read -r -d '' i; do
    result[${#result[@]}]="$i"
  done < <(dc::string::splitN haystack sep "$count")
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[*]:-}" ""
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 0" "${#result[@]}" 0

  count=3
  result=()
  while IFS= read -r -d '' i; do
    result[${#result[@]}]="$i"
  done < <(dc::string::splitN haystack sep "$count")
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[*]:-}" ""
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 3" "${#result[@]}" 0

  count=-1
  result=()
  while IFS= read -r -d '' i; do
    result[${#result[@]}]="$i"
  done < <(dc::string::splitN haystack sep "$count")
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[*]:-}" ""
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 10" "${#result[@]}" 0

  count=invalid$'\n'foo
  result=()
  while IFS= read -r -d '' i; do
    result[${#result[@]}]="$i"
  done < <(dc::string::splitN haystack sep "$count")
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[*]:-}" ""
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 10" "${#result[@]}" 0
}

##########################################
# Null haystack and "whatever" sep
##########################################
testSplitNNullHaystackAndWhateverSep(){
  haystack=
  sep=wha$'\n't$'\t'e$'\0'ver

  count=0
  result=()
  while IFS= read -r -d '' i; do
    result[${#result[@]}]="$i"
  done < <(dc::string::splitN haystack sep "$count")
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[*]:-}" ""
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 0" "${#result[@]}" 0

  count=3
  result=()
  while IFS= read -r -d '' i; do
    result[${#result[@]}]="$i"
  done < <(dc::string::splitN haystack sep "$count")
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[*]:-}" ""
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 3" "${#result[@]}" 0

  count=-1
  result=()
  while IFS= read -r -d '' i; do
    result[${#result[@]}]="$i"
  done < <(dc::string::splitN haystack sep "$count")
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[*]:-}" ""
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 10" "${#result[@]}" 0

  count=invalid$'\n'foo
  result=()
  while IFS= read -r -d '' i; do
    result[${#result[@]}]="$i"
  done < <(dc::string::splitN haystack sep "$count")
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[*]:-}" ""
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 10" "${#result[@]}" 0
}

##########################################
# Null separator and whatever haystack
##########################################
testSplitNWhateverlHaystackAndNullSep(){
  haystack=wha$'\n't$'\t'e$'\0'ver
  sep=

  count=0
  result=()
  while IFS= read -r -d '' i; do
    result[${#result[@]}]="$i"
  done < <(dc::string::splitN haystack sep "$count")
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[*]:-}" ""
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 0" "${#result[@]}" 0

  count=3
  result=()
  while IFS= read -r -d '' i; do
    result[${#result[@]}]="$i"
  done < <(dc::string::splitN haystack sep "$count")
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 3" "${#result[@]}" 3
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[*]:-}" "w h a"

  count=-1
  result=()
  while IFS= read -r -d '' i; do
    result[${#result[@]}]="$i"
  done < <(dc::string::splitN haystack sep "$count")
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[*]:-}" "w h a "$'\n'" t "$'\t'" e "$'\0'"v e r"
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 10" "${#result[@]}" 10

  local exitcode=0
  count=invalid$'\n'foo
  result=()

  local inter
  inter="$(dc::string::splitN haystack sep "$count")" || exitcode=$?

  while IFS= read -r -d '' i; do
    result[${#result[@]}]="$i"
  done <<<"$inter"
  #< <(dc::string::splitN haystack sep $count || {
  #  echo "lol"
  #  exitcode=$?
  #})
  dc-tools::assert::equal "Exit fail" "ARGUMENT_INVALID" "$(dc::error::lookup $exitcode)"
  # dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[*]:-}" "w h a "$'\n'" t "$'\t'" e "$'\0'"v e r"
  # dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 10" "${#result[@]}" 10
}

##########################################
# Non-null separator and haystack
##########################################
testSplitNWhateverHaystackAndWhateverSep(){
  haystack=wha$'\n't$'\t'e$'\0'ver
  sep=a$'\n't

  count=0
  result=()
  while IFS= read -r -d '' i; do
    result[${#result[@]}]="$i"
  done < <(dc::string::splitN haystack sep "$count")
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[*]:-}" ""
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 0" "${#result[@]}" 0

  count=3
  result=()
  while IFS= read -r -d '' i; do
    result[${#result[@]}]="$i"
  done < <(dc::string::splitN haystack sep "$count")
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[0]}" wh
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[1]}" $'\t'e$'\0'ver
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 0" "${#result[@]}" 2

  count=-1
  result=()
  while IFS= read -r -d '' i; do
    result[${#result[@]}]="$i"
  done < <(dc::string::splitN haystack sep "$count")
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[0]}" wh
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[1]}" $'\t'e$'\0'ver
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 0" "${#result[@]}" 2

# XXX not sure but now we are failing if the argument is not int
#  count=invalid$'\n'foo
#  result=()
#  while IFS= read -r -d '' i; do
#    result[${#result[@]}]="$i"
#  done < <(dc::string::splitN haystack sep "$count")
#  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[0]:-}" wh
#  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[1]:-}" $'\t'e$'\0'ver
#  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 0" "${#result[@]}" 2
}

##########################################
# Non-null separator and haystack, separator not part of the string
##########################################
testSplitNNoMatch(){
  haystack=wha$'\n't$'\t'e$'\0'ver
  sep=∞

  count=0
  result=()
  while IFS= read -r -d '' i; do
    result[${#result[@]}]="$i"
  done < <(dc::string::splitN haystack sep "$count")
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[*]:-}" ""
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 0" "${#result[@]}" 0

  count=3
  result=()
  while IFS= read -r -d '' i; do
    result[${#result[@]}]="$i"
  done < <(dc::string::splitN haystack sep "$count")
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[0]}" "$haystack"
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 0" "${#result[@]}" 1

  count=-1
  result=()
  while IFS= read -r -d '' i; do
    result[${#result[@]}]="$i"
  done < <(dc::string::splitN haystack sep "$count")
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[0]}" "$haystack"
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 0" "${#result[@]}" 1

#  count=invalid$'\n'foo
#  result=()
#  while IFS= read -r -d '' i; do
#    result[${#result[@]}]="$i"
#  done < <(dc::string::splitN haystack sep "$count")
#  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[0]}" "$haystack"
#  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 0" "${#result[@]}" 1
}

##########################################
# Non-null separator and haystack, start with separator
##########################################
testSplitNStartWithSep(){
  haystack=wha$'\n't$'\t'e$'\0'ver
  sep=wh

  count=0
  result=()
  while IFS= read -r -d '' i; do
    result[${#result[@]}]="$i"
  done < <(dc::string::splitN haystack sep "$count")
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[*]:-}" ""
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 0" "${#result[@]}" 0

  count=3
  result=()
  while IFS= read -r -d '' i; do
    result[${#result[@]}]="$i"
  done < <(dc::string::splitN haystack sep "$count")
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[0]}" ""
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[1]}" a$'\n't$'\t'e$'\0'ver
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 0" "${#result[@]}" 2

  count=-1
  result=()
  while IFS= read -r -d '' i; do
    result[${#result[@]}]="$i"
  done < <(dc::string::splitN haystack sep "$count")
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[0]}" ""
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[1]}" a$'\n't$'\t'e$'\0'ver
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 0" "${#result[@]}" 2

#  count=invalid$'\n'foo
#  result=()
#  while IFS= read -r -d '' i; do
#    result[${#result[@]}]="$i"
#  done < <(dc::string::splitN haystack sep "$count")
#  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[0]}" ""
#  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[1]}" a$'\n't$'\t'e$'\0'ver
#  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 0" "${#result[@]}" 2
}

##########################################
# Non-null separator and haystack, end with separator
##########################################
testSplitNEndWithSep(){
  haystack=wha$'\n't$'\t'e$'\0'ver
  sep=er

  count=0
  result=()
  while IFS= read -r -d '' i; do
    result[${#result[@]}]="$i"
  done < <(dc::string::splitN haystack sep "$count")
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[*]:-}" ""
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 0" "${#result[@]}" 0

  count=3
  result=()
  while IFS= read -r -d '' i; do
    result[${#result[@]}]="$i"
  done < <(dc::string::splitN haystack sep "$count")
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[0]}" wha$'\n't$'\t'e$'\0'v
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[1]}" ""
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 0" "${#result[@]}" 2

  count=-1
  result=()
  while IFS= read -r -d '' i; do
    result[${#result[@]}]="$i"
  done < <(dc::string::splitN haystack sep "$count")
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[0]}" wha$'\n't$'\t'e$'\0'v
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[1]}" ""
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 0" "${#result[@]}" 2

#  count=invalid$'\n'foo
#  result=()
#  while IFS= read -r -d '' i; do
#    result[${#result[@]}]="$i"
#  done < <(dc::string::splitN haystack sep "$count")
#  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[0]}" wha$'\n't$'\t'e$'\0'v
#  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[1]}" ""
#  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 0" "${#result[@]}" 2
}

##########################################
# Non-null separator and haystack, more than one separator occurence, non-ASCII
##########################################
testSplitNMoreThanOne(){
  haystack="∞ a b c ∞ a b c ∞ a b c ∞"
  sep="∞"

  count=0
  result=()
  while IFS= read -r -d '' i; do
    result[${#result[@]}]="$i"
  done < <(dc::string::splitN haystack sep "$count")
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[*]:-}" ""
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 0" "${#result[@]}" 0

  count=3
  result=()
  while IFS= read -r -d '' i; do
    result[${#result[@]}]="$i"
  done < <(dc::string::splitN haystack sep "$count")
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[0]}" ""
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[1]}" " a b c "
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[2]}" " a b c ∞ a b c ∞"
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 0" "${#result[@]}" 3

  count=-1
  result=()
  while IFS= read -r -d '' i; do
    result[${#result[@]}]="$i"
  done < <(dc::string::splitN haystack sep "$count")
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[0]}" ""
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[1]}" " a b c "
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[2]}" " a b c "
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[3]}" " a b c "
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[4]}" ""
  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 0" "${#result[@]}" 5

#  count=invalid$'\n'foo
#  result=()
#  while IFS= read -r -d '' i; do
#    result[${#result[@]}]="$i"
#  done < <(dc::string::splitN haystack sep "$count")
#  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[0]}" ""
#  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[1]}" " a b c "
#  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[2]}" " a b c "
#  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[3]}" " a b c "
#  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> result: " "${result[4]}" ""
#  dc-tools::assert::equal "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 0" "${#result[@]}" 5
}
