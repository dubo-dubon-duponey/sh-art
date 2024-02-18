#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

testing(){
  echo "Non existent host"
  dc::internal::wrapped::ssh -fla apo@dacodac "ls -lA" || {
    echo "Failed handled 1"
  }

  echo "Bogus command"
  dc::internal::wrapped::ssh --flouzy apo@dacodac "ls -lA" || {
    echo "Failed handled 1 $_DC_PRIVATE_ERROR_DETAIL"
  }

  echo "No ssh"
  dc::internal::wrapped::ssh -p 1234 duncan.st "ls -lA" || {
    echo "Failed handled 2"
  }

  echo "Non existent user"
  dc::internal::wrapped::ssh foobar@dacodac.local "ls -lA" || {
    echo "Failed handled 3"
  }

  echo "Good"
  dc::internal::wrapped::ssh apo@dacodac.local "ls -lA"
}

