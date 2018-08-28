#!/usr/bin/env bash

pattern="1 2 3 a b c"
dc::string::repeat pattern 3
dc-tools::assert::equal "$result" "1 2 3 a b c1 2 3 a b c1 2 3 a b c" "$pattern to be repeated 3 times"

pattern="1 2 3 a b c"
dc::string::repeat pattern 0
dc-tools::assert::equal "$result" "" "$pattern to be repeated 0 times"

pattern="1 2 3 a b c"
dc::string::repeat pattern -1
dc-tools::assert::equal "$result" "" "$pattern to be repeated 0 times"

source="something thin in a tin thing-thing thiner"
search="thin"
replace="∞Foo"
number=-1
dc::string::replace source search $replace $number
dc-tools::assert::equal "$result" "some∞Foog ∞Foo in a tin ∞Foog-∞Foog ∞Fooer" "replace"

dc::string::replace source search "" $number
dc-tools::assert::equal "$result" "someg  in a tin g-g er" "replace"


source="∞Foo"
dc::string::toUpper source
dc-tools::assert::equal "$result" "∞FOO" "upper"
dc::string::toLower source
dc-tools::assert::equal "$result" "∞foo" "upper"


source='  Start here ∞
  foo foo
  bar
∞ stop here  '

dc::string::trimPrefix source '  Start here ∞
'
dc-tools::assert::equal "$result" '  foo foo
  bar
∞ stop here  ' "trimprefix"

dc::string::trimSuffix source '
∞ stop here  '
dc-tools::assert::equal "$result" '  Start here ∞
  foo foo
  bar' "trimsuffix"

dc::string::trimPrefix source 'whatever'
dc-tools::assert::equal "$result" "$source" "trimprefix fail"

dc::string::trimSuffix source 'whatever'
dc-tools::assert::equal "$result" "$source" "trimsuffix fail"

source="    a b d     "
dc::string::trimSpace source
dc-tools::assert::equal "$result" "a b d" "trimspace"
source=".-_+/*\\()[]a b d.-_+/*\\()[]"
chars=".]_[()+/-*\\"
dc::string::trim source $chars
