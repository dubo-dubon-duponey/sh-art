#!/usr/bin/env bash

#### splitN

##########################################
# Null haystack and null sep
##########################################
haystack=
sep=

count=0
result=()
while IFS= read -r -d '' i; do
  result[${#result[@]}]="$i"
done < <(dc::string::splitN haystack sep $count)
dc-tools::assert::equal "${result[*]}" "" "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${#result[@]}" 0 "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 0"

count=3
result=()
while IFS= read -r -d '' i; do
  result[${#result[@]}]="$i"
done < <(dc::string::splitN haystack sep $count)
dc-tools::assert::equal "${result[*]}" "" "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${#result[@]}" 0 "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 3"

count=-1
result=()
while IFS= read -r -d '' i; do
  result[${#result[@]}]="$i"
done < <(dc::string::splitN haystack sep $count)
dc-tools::assert::equal "${result[*]}" "" "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${#result[@]}" 0 "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 10"

count=invalid$'\n'foo
result=()
while IFS= read -r -d '' i; do
  result[${#result[@]}]="$i"
done < <(dc::string::splitN haystack sep $count)
dc-tools::assert::equal "${result[*]}" "" "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${#result[@]}" 0 "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 10"

##########################################
# Null haystack and "whatever" sep
##########################################
haystack=
sep=wha$'\n't$'\t'e$'\0'ver

count=0
result=()
while IFS= read -r -d '' i; do
  result[${#result[@]}]="$i"
done < <(dc::string::splitN haystack sep $count)
dc-tools::assert::equal "${result[*]}" "" "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${#result[@]}" 0 "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 0"

count=3
result=()
while IFS= read -r -d '' i; do
  result[${#result[@]}]="$i"
done < <(dc::string::splitN haystack sep $count)
dc-tools::assert::equal "${result[*]}" "" "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${#result[@]}" 0 "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 3"

count=-1
result=()
while IFS= read -r -d '' i; do
  result[${#result[@]}]="$i"
done < <(dc::string::splitN haystack sep $count)
dc-tools::assert::equal "${result[*]}" "" "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${#result[@]}" 0 "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 10"

count=invalid$'\n'foo
result=()
while IFS= read -r -d '' i; do
  result[${#result[@]}]="$i"
done < <(dc::string::splitN haystack sep $count)
dc-tools::assert::equal "${result[*]}" "" "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${#result[@]}" 0 "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 10"

##########################################
# Null separator and whatever haystack
##########################################
haystack=wha$'\n't$'\t'e$'\0'ver
sep=

count=0
result=()
while IFS= read -r -d '' i; do
  result[${#result[@]}]="$i"
done < <(dc::string::splitN haystack sep $count)
dc-tools::assert::equal "${result[*]}" "" "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${#result[@]}" 0 "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 0"

count=3
result=()
while IFS= read -r -d '' i; do
  result[${#result[@]}]="$i"
done < <(dc::string::splitN haystack sep $count)
dc-tools::assert::equal "${#result[@]}" 3 "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 3"
dc-tools::assert::equal "${result[*]}" "w h a" "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "

count=-1
result=()
while IFS= read -r -d '' i; do
  result[${#result[@]}]="$i"
done < <(dc::string::splitN haystack sep $count)
dc-tools::assert::equal "${result[*]}" "w h a "$'\n'" t "$'\t'" e "$'\0'"v e r" "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${#result[@]}" 10 "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 10"

count=invalid$'\n'foo
result=()
while IFS= read -r -d '' i; do
  result[${#result[@]}]="$i"
done < <(dc::string::splitN haystack sep $count)
dc-tools::assert::equal "${result[*]}" "w h a "$'\n'" t "$'\t'" e "$'\0'"v e r" "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${#result[@]}" 10 "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 10"

##########################################
# Non-null separator and haystack
##########################################
haystack=wha$'\n't$'\t'e$'\0'ver
sep=a$'\n't

count=0
result=()
while IFS= read -r -d '' i; do
  result[${#result[@]}]="$i"
done < <(dc::string::splitN haystack sep $count)
dc-tools::assert::equal "${result[*]}" "" "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${#result[@]}" 0 "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 0"

count=3
result=()
while IFS= read -r -d '' i; do
  result[${#result[@]}]="$i"
done < <(dc::string::splitN haystack sep $count)
dc-tools::assert::equal "${result[0]}" wh "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${result[1]}" $'\t'e$'\0'ver "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${#result[@]}" 2 "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 0"

count=-1
result=()
while IFS= read -r -d '' i; do
  result[${#result[@]}]="$i"
done < <(dc::string::splitN haystack sep $count)
dc-tools::assert::equal "${result[0]}" wh "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${result[1]}" $'\t'e$'\0'ver "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${#result[@]}" 2 "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 0"

count=invalid$'\n'foo
result=()
while IFS= read -r -d '' i; do
  result[${#result[@]}]="$i"
done < <(dc::string::splitN haystack sep $count)
dc-tools::assert::equal "${result[0]}" wh "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${result[1]}" $'\t'e$'\0'ver "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${#result[@]}" 2 "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 0"

##########################################
# Non-null separator and haystack, separator not part of the string
##########################################
haystack=wha$'\n't$'\t'e$'\0'ver
sep=∞

count=0
result=()
while IFS= read -r -d '' i; do
  result[${#result[@]}]="$i"
done < <(dc::string::splitN haystack sep $count)
dc-tools::assert::equal "${result[*]}" "" "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${#result[@]}" 0 "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 0"

count=3
result=()
while IFS= read -r -d '' i; do
  result[${#result[@]}]="$i"
done < <(dc::string::splitN haystack sep $count)
dc-tools::assert::equal "${result[0]}" "$haystack" "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${#result[@]}" 1 "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 0"

count=-1
result=()
while IFS= read -r -d '' i; do
  result[${#result[@]}]="$i"
done < <(dc::string::splitN haystack sep $count)
dc-tools::assert::equal "${result[0]}" "$haystack" "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${#result[@]}" 1 "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 0"

count=invalid$'\n'foo
result=()
while IFS= read -r -d '' i; do
  result[${#result[@]}]="$i"
done < <(dc::string::splitN haystack sep $count)
dc-tools::assert::equal "${result[0]}" "$haystack" "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${#result[@]}" 1 "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 0"

##########################################
# Non-null separator and haystack, start with separator
##########################################
haystack=wha$'\n't$'\t'e$'\0'ver
sep=wh

count=0
result=()
while IFS= read -r -d '' i; do
  result[${#result[@]}]="$i"
done < <(dc::string::splitN haystack sep $count)
dc-tools::assert::equal "${result[*]}" "" "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${#result[@]}" 0 "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 0"

count=3
result=()
while IFS= read -r -d '' i; do
  result[${#result[@]}]="$i"
done < <(dc::string::splitN haystack sep $count)
dc-tools::assert::equal "${result[0]}" "" "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${result[1]}" a$'\n't$'\t'e$'\0'ver "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${#result[@]}" 2 "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 0"

count=-1
result=()
while IFS= read -r -d '' i; do
  result[${#result[@]}]="$i"
done < <(dc::string::splitN haystack sep $count)
dc-tools::assert::equal "${result[0]}" "" "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${result[1]}" a$'\n't$'\t'e$'\0'ver "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${#result[@]}" 2 "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 0"

count=invalid$'\n'foo
result=()
while IFS= read -r -d '' i; do
  result[${#result[@]}]="$i"
done < <(dc::string::splitN haystack sep $count)
dc-tools::assert::equal "${result[0]}" "" "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${result[1]}" a$'\n't$'\t'e$'\0'ver "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${#result[@]}" 2 "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 0"

##########################################
# Non-null separator and haystack, end with separator
##########################################
haystack=wha$'\n't$'\t'e$'\0'ver
sep=er

count=0
result=()
while IFS= read -r -d '' i; do
  result[${#result[@]}]="$i"
done < <(dc::string::splitN haystack sep $count)
dc-tools::assert::equal "${result[*]}" "" "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${#result[@]}" 0 "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 0"

count=3
result=()
while IFS= read -r -d '' i; do
  result[${#result[@]}]="$i"
done < <(dc::string::splitN haystack sep $count)
dc-tools::assert::equal "${result[0]}" wha$'\n't$'\t'e$'\0'v "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${result[1]}" "" "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${#result[@]}" 2 "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 0"

count=-1
result=()
while IFS= read -r -d '' i; do
  result[${#result[@]}]="$i"
done < <(dc::string::splitN haystack sep $count)
dc-tools::assert::equal "${result[0]}" wha$'\n't$'\t'e$'\0'v "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${result[1]}" "" "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${#result[@]}" 2 "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 0"

count=invalid$'\n'foo
result=()
while IFS= read -r -d '' i; do
  result[${#result[@]}]="$i"
done < <(dc::string::splitN haystack sep $count)
dc-tools::assert::equal "${result[0]}" wha$'\n't$'\t'e$'\0'v "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${result[1]}" "" "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${#result[@]}" 2 "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 0"

##########################################
# Non-null separator and haystack, more than one separator occurence, non-ASCII
##########################################
haystack="∞ a b c ∞ a b c ∞ a b c ∞"
sep="∞"

count=0
result=()
while IFS= read -r -d '' i; do
  result[${#result[@]}]="$i"
done < <(dc::string::splitN haystack sep $count)
dc-tools::assert::equal "${result[*]}" "" "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${#result[@]}" 0 "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 0"

count=3
result=()
while IFS= read -r -d '' i; do
  result[${#result[@]}]="$i"
done < <(dc::string::splitN haystack sep $count)
dc-tools::assert::equal "${result[0]}" "" "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${result[1]}" " a b c " "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${result[2]}" " a b c ∞ a b c ∞" "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${#result[@]}" 3 "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 0"

count=-1
result=()
while IFS= read -r -d '' i; do
  result[${#result[@]}]="$i"
done < <(dc::string::splitN haystack sep $count)
dc-tools::assert::equal "${result[0]}" "" "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${result[1]}" " a b c " "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${result[2]}" " a b c " "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${result[3]}" " a b c " "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${result[4]}" "" "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${#result[@]}" 5 "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 0"

count=invalid$'\n'foo
result=()
while IFS= read -r -d '' i; do
  result[${#result[@]}]="$i"
done < <(dc::string::splitN haystack sep $count)
dc-tools::assert::equal "${result[0]}" "" "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${result[1]}" " a b c " "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${result[2]}" " a b c " "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${result[3]}" " a b c " "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${result[4]}" "" "splitN - haystack: $haystack, sep: $sep, count: $count -> result: "
dc-tools::assert::equal "${#result[@]}" 5 "splitN - haystack: $haystack, sep: $sep, count: $count -> count: 0"
