##################################################################
FROM com.dbdbdp.dckr:alpine-38 as alpine-38
# no shellcheck package on alpine
RUN apk add --no-cache make git ncurses gnupg
RUN apk add --no-cache bash grep curl perl-utils libressl jq sqlite
ENV DC_PREFIX=/tmp
USER dckr

##################################################################
FROM com.dbdbdp.dckr:alpine-39 as alpine-39
# no shellcheck package on alpine
RUN apk add --no-cache make git ncurses gnupg
RUN apk add --no-cache bash grep curl perl-utils libressl jq sqlite
ENV DC_PREFIX=/tmp
USER dckr

##################################################################
FROM com.dbdbdp.dckr:alpine-310 as alpine-310
# no shellcheck package on alpine
RUN apk add --no-cache make git ncurses gnupg
RUN apk add --no-cache bash grep curl perl-utils libressl jq sqlite # docker-cli
ENV DC_PREFIX=/tmp
USER dckr

##################################################################
FROM com.dbdbdp.dckr:alpine-311 as alpine-311
# no shellcheck package on alpine
RUN apk add --no-cache make git ncurses gnupg
RUN apk add --no-cache bash grep curl perl-utils libressl jq sqlite # docker-cli
ENV DC_PREFIX=/tmp
USER dckr

##################################################################
FROM com.dbdbdp.dckr:alpine-next as alpine-next
# no shellcheck package on alpine
RUN apk add --no-cache make git ncurses gnupg
RUN apk add --no-cache bash grep curl perl-utils libressl jq sqlite # docker-cli
ENV DC_PREFIX=/tmp
USER dckr

##################################################################
FROM com.dbdbdp.dckr:ubuntu-1404 as ubuntu-1404
RUN apt-get update
RUN apt-get install -y --no-install-recommends make git shellcheck gpgv2 ca-certificates # docker.io
RUN apt-get install -y --no-install-recommends curl jq sqlite3
ENV DC_PREFIX=/tmp
USER dckr

##################################################################
FROM com.dbdbdp.dckr:ubuntu-1604 as ubuntu-1604
RUN apt-get update
RUN apt-get install -y --no-install-recommends make git shellcheck gpgv2 ca-certificates # docker.io
RUN apt-get install -y --no-install-recommends curl jq sqlite3
ENV DC_PREFIX=/tmp
USER dckr

##################################################################
FROM com.dbdbdp.dckr:ubuntu-1804 as ubuntu-1804
RUN apt-get update
RUN apt-get install -y --no-install-recommends make git shellcheck gpgv2 ca-certificates # docker.io
RUN apt-get install -y --no-install-recommends curl jq sqlite3
ENV DC_PREFIX=/tmp
USER dckr

##################################################################
FROM com.dbdbdp.dckr:ubuntu-current as ubuntu-current
RUN apt-get update
RUN apt-get install -y --no-install-recommends make git shellcheck gpg-agent gpg ca-certificates # docker.io
RUN apt-get install -y --no-install-recommends curl jq sqlite3
ENV DC_PREFIX=/tmp
USER dckr

##################################################################
FROM com.dbdbdp.dckr:ubuntu-next as ubuntu-next
RUN apt-get update
RUN apt-get install -y --no-install-recommends make git shellcheck gpg-agent gpg ca-certificates # docker.io
RUN apt-get install -y --no-install-recommends curl jq sqlite3
ENV DC_PREFIX=/tmp
USER dckr

# NOTE: debian typically comes WITHOUT procps - albeit we do not need it formally
##################################################################
FROM com.dbdbdp.dckr:debian-8 as debian-8
RUN apt-get update
RUN apt-get install -y --no-install-recommends make git shellcheck gpgv2 ca-certificates
RUN apt-get install -y --no-install-recommends curl jq sqlite3
ENV DC_PREFIX=/tmp
USER dckr

##################################################################
FROM com.dbdbdp.dckr:debian-9 as debian-9
RUN apt-get update
RUN apt-get install -y --no-install-recommends make git shellcheck gpg ca-certificates
RUN apt-get install -y --no-install-recommends curl jq sqlite3
ENV DC_PREFIX=/tmp
USER dckr

##################################################################
FROM com.dbdbdp.dckr:debian-10 as debian-10
RUN apt-get update
RUN apt-get install -y --no-install-recommends make git shellcheck gpg ca-certificates # docker.io
RUN apt-get install -y --no-install-recommends curl jq sqlite3
ENV DC_PREFIX=/tmp
USER dckr

##################################################################
FROM com.dbdbdp.dckr:debian-current as debian-current
RUN apt-get update
RUN apt-get install -y --no-install-recommends make git shellcheck gpg-agent gpg ca-certificates # docker.io
RUN apt-get install -y --no-install-recommends curl jq sqlite3
ENV DC_PREFIX=/tmp
USER dckr

##################################################################
FROM com.dbdbdp.dckr:debian-next as debian-next
RUN apt-get update
RUN apt-get install -y --no-install-recommends make git shellcheck gpg-agent gpg ca-certificates # docker.io
RUN apt-get install -y --no-install-recommends curl jq sqlite3
ENV DC_PREFIX=/tmp
USER dckr
