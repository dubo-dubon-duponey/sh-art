#!/usr/bin/env bash

#### Split and splitN

# Split slices s into all substrings separated by sep and returns a slice of the substrings between those separators.
haystack='1 1∞1 1 12'$'\r'$'\n''a 1 13'
sep="1 1"
result=()

# read -r -a thing < <(echo "a b cc")
#read -d '' -r -a thing < <(dc::string::split haystack sep)
#read -r -d $'\0' -a thing < <(printf "%s\0%s\0%s" "a" "b" "c")
#echo "${#thing[@]}"
#exit

while IFS= read -r -d '' -a foo; do
  result[${#result[@]}]="$foo"
done < <(dc::string::split haystack sep)

dc-tools::assert::equal "${result[0]}" "" "[0]: '$haystack' split, sep '$sep'"
dc-tools::assert::equal "${result[1]}" "∞" "[1]: '$haystack' split, sep '$sep'"
dc-tools::assert::equal "${result[2]}" ' 12'$'\r'$'\na ' "[2]: '$haystack' split, sep '$sep'"
exit
dc-tools::assert::equal "${result[3]}" 3 "'$haystack' split, sep '$sep'"
dc-tools::assert::equal "${#result[@]}" 4 "'$haystack' split, sep '$sep'"

dc::string::splitAfter haystack sep
dc-tools::assert::equal "${result[0]}" "1 1" "'$haystack' split, sep '$sep'"
dc-tools::assert::equal "${result[1]}" "∞1 1" "'$haystack' split, sep '$sep'"
dc-tools::assert::equal "${result[2]}" ' 12'$'\r''
1 1' "'$haystack' split, sep '$sep'"
dc-tools::assert::equal "${result[3]}" 3 "'$haystack' split, sep '$sep'"
dc-tools::assert::equal "${#result[@]}" 4 "'$haystack' split, sep '$sep'"

dc::string::splitN haystack sep -1
dc-tools::assert::equal "${result[0]}" "" "'$haystack' split, sep '$sep'"
dc-tools::assert::equal "${result[1]}" "∞" "'$haystack' split, sep '$sep'"
dc-tools::assert::equal "${result[2]}" ' 12'$'\r''
' "'$haystack' split, sep '$sep'"
dc-tools::assert::equal "${result[3]}" 3 "'$haystack' split, sep '$sep'"
dc-tools::assert::equal "${#result[@]}" 4 "'$haystack' split, sep '$sep'"

dc::string::splitN haystack sep 100
dc-tools::assert::equal "${result[0]}" "" "'$haystack' split, sep '$sep'"
dc-tools::assert::equal "${result[1]}" "∞" "'$haystack' split, sep '$sep'"
dc-tools::assert::equal "${result[2]}" ' 12'$'\r''
' "'$haystack' split, sep '$sep'"
dc-tools::assert::equal "${result[3]}" 3 "'$haystack' split, sep '$sep'"
dc-tools::assert::equal "${#result[@]}" 4 "'$haystack' split, sep '$sep'"

dc::string::splitAfterN haystack sep 100
dc-tools::assert::equal "${result[0]}" "1 1" "'$haystack' split, sep '$sep'"
dc-tools::assert::equal "${result[1]}" "∞1 1" "'$haystack' split, sep '$sep'"
dc-tools::assert::equal "${result[2]}" ' 12'$'\r''
1 1' "'$haystack' split, sep '$sep'"
dc-tools::assert::equal "${result[3]}" 3 "'$haystack' split, sep '$sep'"
dc-tools::assert::equal "${#result[@]}" 4 "'$haystack' split, sep '$sep'"

dc::string::splitN haystack sep 2
dc-tools::assert::equal "${result[0]}" "" "'$haystack' split, sep '$sep'"
dc-tools::assert::equal "${result[1]}" "∞" "'$haystack' split, sep '$sep'"
dc-tools::assert::equal "${result[2]}" ' 12'$'\r''
1 13' "'$haystack' split, sep '$sep'"
dc-tools::assert::equal "${#result[@]}" 3 "'$haystack' split, sep '$sep'"

dc::string::splitAfterN haystack sep 2
dc-tools::assert::equal "${result[0]}" "1 1" "'$haystack' split, sep '$sep'"
dc-tools::assert::equal "${result[1]}" "∞1 1" "'$haystack' split, sep '$sep'"
dc-tools::assert::equal "${result[2]}" ' 12'$'\r''
1 13' "'$haystack' split, sep '$sep'"
dc-tools::assert::equal "${#result[@]}" 3 "'$haystack' split, sep '$sep'"


# If s does not contain sep and sep is not empty, Split returns a slice of length 1 whose only element is s.
haystack="∞ ∞ ∞ ∞"
sep="1"
dc::string::split haystack sep
dc-tools::assert::equal "${result[0]}" "∞ ∞ ∞ ∞" "'$haystack' split, sep '$sep'"
dc-tools::assert::equal "${#result[@]}" 1 "'$haystack' split, sep '$sep'"

dc::string::splitN haystack sep 1
dc-tools::assert::equal "${result[0]}" "∞ ∞ ∞ ∞" "'$haystack' split, sep '$sep'"
dc-tools::assert::equal "${#result[@]}" 1 "'$haystack' split, sep '$sep'"

dc::string::splitN haystack sep 0
dc-tools::assert::equal "${result[@]}" "" "'$haystack' split, sep '$sep'"

# If sep is empty, Split splits after each UTF-8 sequence. If both s and sep are empty, Split returns an empty slice.
haystack="∞ 2 ∞ ∞"
sep=""
dc::string::split haystack sep
dc-tools::assert::equal "${result[2]}" 2 "'$haystack' split, sep '$sep'"
dc-tools::assert::equal "${#result[@]}" 7 "'$haystack' split, sep '$sep'"

# If both haystack and separator are the empty string, return a zero length array
haystack=
sep=
dc::string::split haystack sep
dc-tools::assert::equal "${#result[@]}" 0 "'$haystack' split, sep '$sep'"
