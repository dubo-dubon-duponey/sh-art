##################################################################
FROM com.dbdbdp.dckr:alpine-current as alpine-current
# no shellcheck package on alpine
RUN apk add --no-cache make git bash ncurses grep gnupg
RUN apk add --no-cache file curl jq ffmpeg sqlite

##################################################################
# For reference, but too busted for sh.art
#FROM com.dbdbdp.dckr:ubuntu-lts-old as ubuntu-lts-old
#RUN apt-get install -y make git shellcheck
#RUN apt-get install -y file curl jq sqlite

##################################################################
FROM com.dbdbdp.dckr:ubuntu-lts-previous as ubuntu-lts-previous
RUN apt-get install -y make git shellcheck
# ffmpeg is too old, shellcheck is too old as well
RUN apt-get install -y file curl jq ffmpeg sqlite

##################################################################
FROM com.dbdbdp.dckr:ubuntu-lts-current as ubuntu-lts-current
RUN apt-get install -y make git shellcheck gpg
RUN apt-get install -y file curl jq ffmpeg sqlite

##################################################################
#FROM com.dbdbdp.dckr:ubuntu-next as ubuntu-next
#RUN apt-get install -y make git shellcheck gpg
#RUN apt-get install -y file curl jq ffmpeg sqlite

##################################################################
FROM com.dbdbdp.dckr:debian-current as debian-current
RUN apt-get install -y make git shellcheck gpg
RUN apt-get install -y file curl jq ffmpeg sqlite

##################################################################
FROM com.dbdbdp.dckr:debian-next as debian-next
RUN apt-get install -y make git shellcheck gpg
RUN apt-get install -y file curl jq ffmpeg sqlite
