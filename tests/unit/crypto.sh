#!/usr/bin/env bash

. source/lib/crypto.sh

testShasumCompute(){
  local result
  local exitcode

  exitcode=0
  dc::crypto::shasum::compute /bogus || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} bogus file error" "BINARY_UNKNOWN_ERROR" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::crypto::shasum::compute /usr/bin || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} bogus file error" "BINARY_UNKNOWN_ERROR" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::crypto::shasum::compute <(printf "something") "bogus algorithm" || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} bogus algorithm error" "CRYPTO_SHASUM_WRONG_ALGORITHM" "$(dc::error::lookup $exitcode)"

  exitcode=0
  result="$(dc::crypto::shasum::compute <(printf "something") "$DC_CRYPTO_SHASUM_1")" || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} something 1" "0" "$exitcode"
  dc-tools::assert::equal "${FUNCNAME[0]} something 1 result" "1af17e73721dbe0c40011b82ed4bb1a7dbe3ce29" "$result"

  exitcode=0
  result="$(dc::crypto::shasum::compute <(printf "something") "$DC_CRYPTO_SHASUM_224")" || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} something 224" "0" "$exitcode"
  dc-tools::assert::equal "${FUNCNAME[0]} something 224 result" "3ea5e0d9d5dc6d8abf5c41bd312adbaa73ee36423bf85e503a9bfd52" "$result"

  exitcode=0
  result="$(dc::crypto::shasum::compute <(printf "something") "$DC_CRYPTO_SHASUM_256")" || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} something 256" "0" "$exitcode"
  dc-tools::assert::equal "${FUNCNAME[0]} something 256 result" "3fc9b689459d738f8c88a3a48aa9e33542016b7a4052e001aaa536fca74813cb" "$result"

  exitcode=0
  result="$(dc::crypto::shasum::compute <(printf "something") "$DC_CRYPTO_SHASUM_384")" || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} something 384" "0" "$exitcode"
  dc-tools::assert::equal "${FUNCNAME[0]} something 384 result" "3ae3c5fc342497c274c50f11609eecc460328cf0b6027d865bf205955c81e4c646544eb9630ba0aaa42753bbf5b8d20a" "$result"

  exitcode=0
  result="$(dc::crypto::shasum::compute <(printf "something") "$DC_CRYPTO_SHASUM_512")" || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} something 512" "0" "$exitcode"
  dc-tools::assert::equal "${FUNCNAME[0]} something 512 result" "983d43ddff6da90f6a5d3b6172446a1ffe228b803fe64fdd5dcfab5646078a896851fe82f623c9d6e5654b3d2f363a04ec17cfb62b607437a9c7c132d511e522" "$result"

  exitcode=0
  result="$(dc::crypto::shasum::compute <(printf "something") "$DC_CRYPTO_SHASUM_512224")" || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} something 512224" "0" "$exitcode"
  dc-tools::assert::equal "${FUNCNAME[0]} something 512224 result" "f18975dba38de7ebf94ddd71f53178a7dddf880a5dccf7693ddf306e" "$result"

  exitcode=0
  result="$(dc::crypto::shasum::compute <(printf "something") "$DC_CRYPTO_SHASUM_512256")" || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} something 512256" "0" "$exitcode"
  dc-tools::assert::equal "${FUNCNAME[0]} something 512256 result" "c510ba121f56281ff78014e7243c961ef599afd446c67ccddcf67f6e74618125" "$result"
}

testShasumVerify(){
  local result
  local exitcode

  exitcode=0
  dc::crypto::shasum::verify "123" /bogus || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} bogus verify file error" "BINARY_UNKNOWN_ERROR" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::crypto::shasum::verify "123" /usr/bin || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} bogus verify dir error" "BINARY_UNKNOWN_ERROR" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::crypto::shasum::verify "123" <(printf "something") "bogus algorithm" || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} bogus verify algorithm error" "CRYPTO_SHASUM_WRONG_ALGORITHM" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::crypto::shasum::verify "sha123:1234" <(printf "something") "does not matter" || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} bogus verify algorithm error" "CRYPTO_SHASUM_WRONG_ALGORITHM" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::crypto::shasum::verify "sha256:1234" <(printf "something") "does not matter" || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} wrong shasum" "CRYPTO_SHASUM_VERIFY_ERROR" "$(dc::error::lookup $exitcode)"

  exitcode=0
  result="$(dc::crypto::shasum::verify 1af17e73721dbe0c40011b82ed4bb1a7dbe3ce29 <(printf "something") "$DC_CRYPTO_SHASUM_1")" || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} something 1" "0" "$exitcode"

  exitcode=0
  result="$(dc::crypto::shasum::verify 3ea5e0d9d5dc6d8abf5c41bd312adbaa73ee36423bf85e503a9bfd52 <(printf "something") "$DC_CRYPTO_SHASUM_224")" || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} something 224" "0" "$exitcode"

  exitcode=0
  result="$(dc::crypto::shasum::verify 3fc9b689459d738f8c88a3a48aa9e33542016b7a4052e001aaa536fca74813cb <(printf "something") "$DC_CRYPTO_SHASUM_256")" || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} something 256" "0" "$exitcode"

  exitcode=0
  result="$(dc::crypto::shasum::verify 3ae3c5fc342497c274c50f11609eecc460328cf0b6027d865bf205955c81e4c646544eb9630ba0aaa42753bbf5b8d20a <(printf "something") "$DC_CRYPTO_SHASUM_384")" || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} something 384" "0" "$exitcode"

  exitcode=0
  result="$(dc::crypto::shasum::verify 983d43ddff6da90f6a5d3b6172446a1ffe228b803fe64fdd5dcfab5646078a896851fe82f623c9d6e5654b3d2f363a04ec17cfb62b607437a9c7c132d511e522 <(printf "something") "$DC_CRYPTO_SHASUM_512")" || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} something 512" "0" "$exitcode"

  exitcode=0
  result="$(dc::crypto::shasum::verify f18975dba38de7ebf94ddd71f53178a7dddf880a5dccf7693ddf306e <(printf "something") "$DC_CRYPTO_SHASUM_512224")" || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} something 512224" "0" "$exitcode"

  exitcode=0
  result="$(dc::crypto::shasum::verify c510ba121f56281ff78014e7243c961ef599afd446c67ccddcf67f6e74618125 <(printf "something") "$DC_CRYPTO_SHASUM_512256")" || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} something 512256" "0" "$exitcode"

  exitcode=0
  result="$(dc::crypto::shasum::verify c510ba121f56281ff78014e7243c961ef599afd446c67ccddcf67f6e74618125 <(printf "something"))" || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} something fallback 512256" "0" "$exitcode"

  exitcode=0
  result="$(dc::crypto::shasum::verify "sha$DC_CRYPTO_SHASUM_1:1af17e73721dbe0c40011b82ed4bb1a7dbe3ce29" <(printf "something") "ignored")" || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} something 1" "0" "$exitcode"

  exitcode=0
  result="$(dc::crypto::shasum::verify "sha$DC_CRYPTO_SHASUM_224:3ea5e0d9d5dc6d8abf5c41bd312adbaa73ee36423bf85e503a9bfd52" <(printf "something") "ignored")" || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} something 224" "0" "$exitcode"

  exitcode=0
  result="$(dc::crypto::shasum::verify "sha$DC_CRYPTO_SHASUM_256:3fc9b689459d738f8c88a3a48aa9e33542016b7a4052e001aaa536fca74813cb" <(printf "something") "ignored")" || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} something 256" "0" "$exitcode"

  exitcode=0
  result="$(dc::crypto::shasum::verify "sha$DC_CRYPTO_SHASUM_384:3ae3c5fc342497c274c50f11609eecc460328cf0b6027d865bf205955c81e4c646544eb9630ba0aaa42753bbf5b8d20a" <(printf "something") "ignored")" || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} something 384" "0" "$exitcode"

  exitcode=0
  result="$(dc::crypto::shasum::verify "sha$DC_CRYPTO_SHASUM_512:983d43ddff6da90f6a5d3b6172446a1ffe228b803fe64fdd5dcfab5646078a896851fe82f623c9d6e5654b3d2f363a04ec17cfb62b607437a9c7c132d511e522" <(printf "something") "ignored")" || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} something 512" "0" "$exitcode"

  exitcode=0
  result="$(dc::crypto::shasum::verify "sha$DC_CRYPTO_SHASUM_512224:f18975dba38de7ebf94ddd71f53178a7dddf880a5dccf7693ddf306e" <(printf "something") "ignored")" || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} something 512224" "0" "$exitcode"

  exitcode=0
  result="$(dc::crypto::shasum::verify "sha$DC_CRYPTO_SHASUM_512256:c510ba121f56281ff78014e7243c961ef599afd446c67ccddcf67f6e74618125" <(printf "something") "ignored")" || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} something 512256" "0" "$exitcode"
}

testECNew(){
  local exitcode

  exitcode=0
  dc::crypto::ec::new > /dev/null || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} exit success" "0" "$exitcode"
}

testECPublic(){
  local exitcode

  exitcode=0
  dc::crypto::ec::public < /usr/bin/env || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} exit fail" "CRYPTO_SSL_INVALID_KEY" "$(dc::error::lookup $exitcode)"

  exitcode=0
  printf "" | dc::crypto::ec::public || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} exit fail" "CRYPTO_SSL_INVALID_KEY" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::crypto::ec::public < tests/fixtures/key-public.pem || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} exit fail" "CRYPTO_SSL_INVALID_KEY" "$(dc::error::lookup $exitcode)"

  # XXX this will STILL prompt for password, which we do not want
  exitcode=0
  #cat tests/fixtures/key-encrypted.pem | dc::crypto::ec::public 2>/dev/null || exitcode=$?
  #dc-tools::assert::equal "${FUNCNAME[0]} exit fail" "$CRYPTO_SSL_KEY_INVALID" "$?"

  exitcode=0
  #cat tests/fixtures/key-pkcs8.pem | dc::crypto::ec::public 2>/dev/null || exitcode=$?
  #dc-tools::assert::equal "${FUNCNAME[0]} exit fail" "$CRYPTO_SSL_KEY_INVALID" "$?"

  exitcode=0
  result="$(dc::crypto::ec::public < tests/fixtures/key-private.pem)" || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} exit success" "0" "$exitcode"
  dc-tools::assert::equal "${FUNCNAME[0]} success result" "$(cat tests/fixtures/key-public.pem)" "$result"
}

testECEncrypt(){
  local exitcode

  exitcode=0
  dc::crypto::ec::encrypt "password this" < /usr/bin/env || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} exit fail" "CRYPTO_SSL_INVALID_KEY" "$(dc::error::lookup $exitcode)"

  exitcode=0
  printf "" | dc::crypto::ec::encrypt "password this" || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} exit fail" "CRYPTO_SSL_INVALID_KEY" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::crypto::ec::encrypt "" < tests/fixtures/key-private.pem || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} exit fail" "CRYPTO_SSL_WRONG_PASSWORD" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::crypto::ec::encrypt "password this" < tests/fixtures/key-private.pem > /dev/null || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} exit success" "0" "$exitcode"
  # dc-tools::assert::equal "success result" "$(cat tests/fixtures/key-encrypted.pem)" "$result"
}

testECDecrypt(){
  local exitcode

  exitcode=0
  dc::crypto::ec::decrypt "password this" < /usr/bin/env || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} exit fail" "CRYPTO_SSL_INVALID_KEY" "$(dc::error::lookup $exitcode)"

  exitcode=0
  printf "" | dc::crypto::ec::decrypt "password this" || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} exit fail" "CRYPTO_SSL_INVALID_KEY" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::crypto::ec::decrypt "" < tests/fixtures/key-encrypted.pem || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} exit fail" "CRYPTO_SSL_WRONG_PASSWORD" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::crypto::ec::decrypt "something else" < tests/fixtures/key-encrypted.pem || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} exit fail" "CRYPTO_SSL_WRONG_PASSWORD" "$(dc::error::lookup $exitcode)"

  exitcode=0
  result="$(dc::crypto::ec::decrypt "password this" < tests/fixtures/key-encrypted.pem)" || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} exit success" "0" "$exitcode"
  dc-tools::assert::equal "success result" "$(cat tests/fixtures/key-private.pem)" "$result"
}

testECtoPKCS8(){
  local exitcode

  exitcode=0
  dc::crypto::ec::to::pkcs8 "password this" < /usr/bin/env || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} exit fail" "CRYPTO_SSL_INVALID_KEY" "$(dc::error::lookup $exitcode)"

  exitcode=0
  printf "" | dc::crypto::ec::to::pkcs8 "password this" || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} exit fail" "CRYPTO_SSL_INVALID_KEY" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::crypto::ec::to::pkcs8 "" < tests/fixtures/key-private.pem || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} exit fail" "CRYPTO_SSL_WRONG_PASSWORD" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::crypto::ec::to::pkcs8 "password this" < tests/fixtures/key-private.pem > /dev/null || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} exit success" "0" "$exitcode"
}

testPKCS8toEC(){
  local exitcode

  exitcode=0
  dc::crypto::pkcs8::to::ec "password this" < /usr/bin/env || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} exit fail" "CRYPTO_SSL_INVALID_KEY" "$(dc::error::lookup $exitcode)"

  exitcode=0
  printf "" | dc::crypto::pkcs8::to::ec "password this" || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} exit fail" "CRYPTO_SSL_INVALID_KEY" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::crypto::pkcs8::to::ec "" < tests/fixtures/key-encrypted.pem || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} exit fail" "CRYPTO_SSL_WRONG_PASSWORD" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::crypto::pkcs8::to::ec "something else" < tests/fixtures/key-encrypted.pem || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} exit fail" "CRYPTO_SSL_WRONG_PASSWORD" "$(dc::error::lookup $exitcode)"

  exitcode=0
  result="$(dc::crypto::pkcs8::to::ec "password this" < tests/fixtures/key-encrypted.pem)" || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} exit success" "0" "$exitcode"
  dc-tools::assert::equal "success result" "$(cat tests/fixtures/key-private.pem)" "$result"
}

testCSRnew(){
  local exitcode

  exitcode=0
  dc::crypto::csr::new < /usr/bin/env || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} exit fail" "CRYPTO_SSL_INVALID_KEY" "$(dc::error::lookup $exitcode)"

  exitcode=0
  printf "" | dc::crypto::csr::new || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} exit fail" "CRYPTO_SSL_INVALID_KEY" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::crypto::csr::new < tests/fixtures/key-private.pem > /dev/null || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} exit wrong args" "CRYPTO_SSL_WRONG_ARGUMENTS" "$(dc::error::lookup $exitcode)"

  exitcode=0
  dc::crypto::csr::new US CA "San Francisco" "Org"$'\n'"Thing" "Unit" "Foo"$'\n'"Bar" "foo@bar.com" < tests/fixtures/key-private.pem > /dev/null || exitcode=$?
  dc-tools::assert::equal "${FUNCNAME[0]} exit success" "0" "$exitcode"
}
