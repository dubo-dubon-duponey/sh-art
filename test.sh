#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

trap::exit(){
        echo exit
        echo "$@"
}

trap::err(){
        echo err
        echo "$@"
}

trap 'trap::exit            "$LINENO" "$?" "$BASH_COMMAND"' EXIT
trap 'trap::err             "$LINENO" "$?" "$BASH_COMMAND"' ERR


foo(){
        local bar
        echo "foo: $bar"
}


foo

echo out of it
