#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

. source/headers/ssh.sh
. source/lib/ssh.sh


testing(){
  exitcode=0
  dc::internal::wrapped::ssh -zzz apo@dacodac ls -lA || exitcode="$?"
  dc-tools::assert::equal "Wrong arguments" "ARGUMENT_INVALID" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::internal::wrapped::ssh --flouzy apo@dacodac ls -lA || exitcode="$?"
  dc-tools::assert::equal "" "ARGUMENT_INVALID" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::internal::wrapped::ssh -p 1234 duncan.st ls -lA || exitcode="$?"
  dc-tools::assert::equal "No SSH" "SSH_CLIENT_CONNECTION" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::internal::wrapped::ssh -o "StrictHostKeyChecking=no" foobar@dacodac.local ls -lA || exitcode="$?"
  dc-tools::assert::equal "Wrong user" "SSH_CLIENT_AUTHENTICATION" "$(dc::error::lookup $exitcode)"

  [ "$HOME" != /home/dckr ] || startSkipping
  exitcode=0
  dc::internal::wrapped::ssh apo@dacodac.local ls -lA >/dev/null || exitcode="$?"
  dc-tools::assert::equal "OK" "NO_ERROR" "$(dc::error::lookup $exitcode)"
  [ "$HOME" != /home/dckr ] || endSkipping
}
