#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

testInternalWrapNormal(){
  local exitcode
  exitcode=0
  dc::internal::securewrap ls >/dev/null || exitcode=$?
  dc-tools::assert::equal "normal ls" "0" "$exitcode"
}

testInternalWrapNoPath(){
  local exitcode
  exitcode=0
  PATH="" dc::internal::securewrap ls >/dev/null || exitcode=$?
  dc-tools::assert::equal "no path ls" "0" "$exitcode"
}

testInternalWrapSameOutput(){
  local exitcode
  exitcode=0
  dc-tools::assert::equal "same output" "$(dc::internal::securewrap ls)" "$(ls)"
}

testInternalWrapBash3(){
  # Only test bash3
  bash --version | grep " 3." >/dev/null || return 0

  a(){
    ls >/dev/null
    cat "$1"
  }

  b(){
    cat "$1"
  }

  c(){
    dc::internal::securewrap ls >/dev/null
    cat "$1"
  }

  exitcode=0
  a <(printf "1\n") >/dev/null 2>&1 || exitcode="$?"

  bv="$(dc::internal::version::get bash)"
  if [ "${bv%.*}" == 3 ]; then
    dc-tools::assert::equal "bash3 shitting itself" "1" "$exitcode"
  else
    dc-tools::assert::equal "bash other work fine" "0" "$exitcode"
  fi

  exitcode=0
  b <(printf "1\n") >/dev/null || exitcode="$?"
  dc-tools::assert::equal "no error" "0" "$exitcode"

  exitcode=0
  c <(printf "1\n") >/dev/null || exitcode="$?"
  dc-tools::assert::equal "no error" "0" "$exitcode"
}



testInternalVarNormTransform(){
  local exitcode
  local result

  exitcode=0
  result="$(dc::internal::varnorm "foobar-baz")" || exitcode=$?
  dc-tools::assert::equal "varnorm" "0" "$exitcode"
  dc-tools::assert::equal "varnorm" "FOOBAR_BAZ" "$result"
}

testInternalVarNormMissingTR(){
  local exitcode
  local result

  tr(){
    missing_binary "$@"
  }

  exitcode=0
  result="$(PATH="" dc::internal::varnorm "foobar-baz")" || exitcode=$?
  dc-tools::assert::equal "varnorm" "144" "$exitcode"
  dc-tools::assert::equal "varnorm" "" "$result"

  exitcode=0
  result="$(PATH="" dc::internal::varnorm "foobar_baz")" || exitcode=$?
  dc-tools::assert::equal "varnorm" "0" "$exitcode"
  dc-tools::assert::equal "varnorm" "foobar_baz" "$result"
}

testInternalVarNormBarfingTR(){
  local exitcode
  local result

  tr(){
    # cat /dev/stdin
    return 42
  }

  exitcode=0
  result="$(PATH="" dc::internal::varnorm "foobar-baz")" || exitcode=$?
  dc-tools::assert::equal "varnorm" "144" "$exitcode"
  dc-tools::assert::equal "varnorm" "" "$result"

  exitcode=0
  result="$(PATH="" dc::internal::varnorm "foobar_baz")" || exitcode=$?
  dc-tools::assert::equal "varnorm" "0" "$exitcode"
  dc-tools::assert::equal "varnorm" "foobar_baz" "$result"
}

testInternalVersionGetMissingBinary(){
  local exitcode
  local result

  exitcode=0
  result="$(dc::internal::version::get missingbinary)" || exitcode=$?
  dc-tools::assert::equal "vget" "0" "$exitcode"
  dc-tools::assert::equal "vget" "" "$result"
}

testInternalVersionGetBorkedBinary(){
  local exitcode
  local result

  bork(){
    exit 42
  }

  exitcode=0
  result="$(dc::internal::version::get bork)" || exitcode=$?
  dc-tools::assert::equal "vget" "0" "$exitcode"
  dc-tools::assert::equal "vget" "" "$result"
}

testInternalVersionGetOkBinary(){
  local exitcode
  local result

  bin1(){
    echo not 42.42not
  }

  bin2(){
    echo not 42not
  }

  bin3(){
    echo not 4not
  }

  bin4(){
    echo not 4.4not
  }

  bin5(){
    echo not 42.42.42not
  }

  exitcode=0
  result="$(PATH="" dc::internal::version::get bin1)" || exitcode=$?
  dc-tools::assert::equal "vget" "0" "$exitcode"
  dc-tools::assert::equal "vget" "42.42" "$result"

  exitcode=0
  result="$(PATH="" dc::internal::version::get bin2)" || exitcode=$?
  dc-tools::assert::equal "vget" "0" "$exitcode"
  dc-tools::assert::equal "vget" "42" "$result"

  exitcode=0
  result="$(PATH="" dc::internal::version::get bin3)" || exitcode=$?
  dc-tools::assert::equal "vget" "0" "$exitcode"
  dc-tools::assert::equal "vget" "4" "$result"

  exitcode=0
  result="$(PATH="" dc::internal::version::get bin4)" || exitcode=$?
  dc-tools::assert::equal "vget" "0" "$exitcode"
  dc-tools::assert::equal "vget" "4.4" "$result"

  exitcode=0
  result="$(PATH="" dc::internal::version::get bin5)" || exitcode=$?
  dc-tools::assert::equal "vget" "0" "$exitcode"
  dc-tools::assert::equal "vget" "42.42" "$result"


}

testInternalVersionCustomOkBinary(){
  local exitcode
  local result

  bin(){
    if [ "$1" == "--give-it-to-me" ]; then
      echo 42
    fi
  }

  exitcode=0
  result="$(PATH="" dc::internal::version::get bin --give-it-to-me)" || exitcode=$?
  dc-tools::assert::equal "vget" "0" "$exitcode"
  dc-tools::assert::equal "vget" "42" "$result"

  exitcode=0
  result="$(PATH="" dc::internal::version::get bin)" || exitcode=$?
  dc-tools::assert::equal "vget" "0" "$exitcode"
  dc-tools::assert::equal "vget" "" "$result"

}

testInternalVersionCustomOkBinary(){
  local exitcode
  local result

  bin(){
    echo "lol42.32lol"
    echo "lol1.2.3.4lol"
  }

  exitcode=0
  result="$(PATH="" dc::internal::version::get bin --give-it-to-me)" || exitcode=$?
  dc-tools::assert::equal "vget" "0" "$exitcode"
  dc-tools::assert::equal "vget" "42.32" "$result"
}
