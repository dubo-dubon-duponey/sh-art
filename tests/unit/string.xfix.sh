#!/usr/bin/env bash

haystack="foo"
needle="foo"
dc::string::hasSuffix haystack $needle
dc-tools::assert::equal "$result" true "$needle in $haystack"
dc::string::hasPrefix haystack $needle
dc-tools::assert::equal "$result" true "$needle in $haystack"

haystack="foo"
needle="o"
dc::string::hasSuffix haystack $needle
dc-tools::assert::equal "$result" true "$needle in $haystack"
dc::string::hasPrefix haystack $needle
dc-tools::assert::equal "$result" false "$needle in $haystack"

haystack="foo"
needle="f"
dc::string::hasSuffix haystack $needle
dc-tools::assert::equal "$result" false "$needle in $haystack"
dc::string::hasPrefix haystack $needle
dc-tools::assert::equal "$result" true "$needle in $haystack"

haystack="foo"
needle=""
dc::string::hasPrefix haystack $needle
dc-tools::assert::equal "$result" true "$needle in $haystack"
dc::string::hasSuffix haystack $needle
dc-tools::assert::equal "$result" true "$needle in $haystack"

haystack=""
needle="o"
dc::string::hasSuffix haystack $needle
dc-tools::assert::equal "$result" false "$needle in $haystack"
dc::string::hasPrefix haystack $needle
dc-tools::assert::equal "$result" false "$needle in $haystack"

haystack=""
needle=""
dc::string::hasSuffix haystack $needle
dc-tools::assert::equal "$result" true "$needle in $haystack"
dc::string::hasPrefix haystack $needle
dc-tools::assert::equal "$result" true "$needle in $haystack"
