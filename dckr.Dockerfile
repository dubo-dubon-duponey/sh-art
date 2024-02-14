##################################################################
FROM com.dbdbdp.dckr:alpine-316 as alpine-316
# no shellcheck package on alpine
RUN apk add --no-cache make git ncurses gnupg
RUN apk add --no-cache bash grep curl perl-utils libressl jq sqlite # docker-cli
ENV DC_PREFIX=/tmp
USER dckr

##################################################################
FROM com.dbdbdp.dckr:alpine-317 as alpine-317
# no shellcheck package on alpine
RUN apk add --no-cache make git ncurses gnupg
RUN apk add --no-cache bash grep curl perl-utils libressl jq sqlite # docker-cli
ENV DC_PREFIX=/tmp
USER dckr

##################################################################
FROM com.dbdbdp.dckr:alpine-318 as alpine-318
# no shellcheck package on alpine
RUN apk add --no-cache make git ncurses gnupg
RUN apk add --no-cache bash grep curl perl-utils libressl jq sqlite # docker-cli
ENV DC_PREFIX=/tmp
USER dckr

##################################################################
FROM com.dbdbdp.dckr:alpine-319 as alpine-319
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
FROM com.dbdbdp.dckr:ubuntu-2004 as ubuntu-2004
RUN apt-get update
RUN apt-get install -y --no-install-recommends make git shellcheck gpg-agent gpg ca-certificates # docker.io
RUN apt-get install -y --no-install-recommends curl jq sqlite3
ENV DC_PREFIX=/tmp
USER dckr

##################################################################
FROM com.dbdbdp.dckr:ubuntu-2204 as ubuntu-2204
RUN apt-get update
RUN apt-get install -y --no-install-recommends make git shellcheck gpg-agent gpg ca-certificates # docker.io
RUN apt-get install -y --no-install-recommends curl jq sqlite3
ENV DC_PREFIX=/tmp
USER dckr

##################################################################
FROM com.dbdbdp.dckr:ubuntu-2204 as ubuntu-2404
RUN apt-get update
RUN apt-get install -y --no-install-recommends make git shellcheck gpg-agent gpg ca-certificates # docker.io
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
FROM com.dbdbdp.dckr:debian-10 as debian-10
RUN apt-get update
RUN apt-get install -y --no-install-recommends make git shellcheck gpg ca-certificates # docker.io
RUN apt-get install -y --no-install-recommends curl jq sqlite3
ENV DC_PREFIX=/tmp
USER dckr

##################################################################
FROM com.dbdbdp.dckr:debian-11 as debian-11
RUN apt-get update
RUN apt-get install -y --no-install-recommends make git shellcheck gpg ca-certificates # docker.io
RUN apt-get install -y --no-install-recommends curl jq sqlite3
ENV DC_PREFIX=/tmp
USER dckr

##################################################################
FROM com.dbdbdp.dckr:debian-12 as debian-12
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
