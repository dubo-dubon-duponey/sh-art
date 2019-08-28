##################################################################
FROM com.dbdbdp.dckr:alpine-current as alpine-current
# no shellcheck package on alpine
RUN apk add --no-cache make git ncurses gnupg
RUN apk add --no-cache bash grep curl perl-utils libressl jq sqlite
ENV DC_PREFIX=/tmp
USER dckr

##################################################################
FROM com.dbdbdp.dckr:alpine-next as alpine-next
# no shellcheck package on alpine
RUN apk add --no-cache make git ncurses gnupg
RUN apk add --no-cache bash grep curl perl-utils libressl jq sqlite
ENV DC_PREFIX=/tmp
USER dckr

##################################################################
FROM com.dbdbdp.dckr:ubuntu-lts-old as ubuntu-lts-old
RUN apt-get update
RUN apt-get install -y --no-install-recommends make git shellcheck ca-certificates
RUN apt-get install -y --no-install-recommends curl jq sqlite3
ENV DC_PREFIX=/tmp
USER dckr

##################################################################
FROM com.dbdbdp.dckr:ubuntu-lts-current as ubuntu-lts-current
RUN apt-get update
RUN apt-get install -y --no-install-recommends make git shellcheck gpg ca-certificates
RUN apt-get install -y --no-install-recommends curl jq sqlite3
ENV DC_PREFIX=/tmp
USER dckr

##################################################################
FROM com.dbdbdp.dckr:ubuntu-current as ubuntu-current
RUN apt-get update
RUN apt-get install -y --no-install-recommends make git shellcheck gpg ca-certificates
RUN apt-get install -y --no-install-recommends curl jq sqlite3
ENV DC_PREFIX=/tmp
USER dckr

##################################################################
FROM com.dbdbdp.dckr:ubuntu-next as ubuntu-next
RUN apt-get update
RUN apt-get install -y --no-install-recommends make git shellcheck gpg ca-certificates
RUN apt-get install -y --no-install-recommends curl jq sqlite3
ENV DC_PREFIX=/tmp
USER dckr

# NOTE: debian typically comes WITHOUT procps - albeit we do not need it formally
##################################################################
FROM com.dbdbdp.dckr:debian-old as debian-old
RUN apt-get update
RUN apt-get install -y --no-install-recommends make git shellcheck gpg ca-certificates
RUN apt-get install -y --no-install-recommends curl jq sqlite3
ENV DC_PREFIX=/tmp
USER dckr

##################################################################
FROM com.dbdbdp.dckr:debian-current as debian-current
RUN apt-get update
RUN apt-get install -y --no-install-recommends make git shellcheck gpg ca-certificates
RUN apt-get install -y --no-install-recommends curl jq sqlite3
ENV DC_PREFIX=/tmp
USER dckr

##################################################################
FROM com.dbdbdp.dckr:debian-next as debian-next
RUN apt-get update
RUN apt-get install -y --no-install-recommends make git shellcheck gpg ca-certificates
RUN apt-get install -y --no-install-recommends curl jq sqlite3
ENV DC_PREFIX=/tmp
USER dckr
