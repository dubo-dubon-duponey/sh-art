##################################################################
### Base images
##################################################################
FROM alpine:3.8 as base-alpine-current

FROM debian:stretch as base-deb-current
FROM debian:buster as base-deb-next

# Trusty is too busted
# FROM ubuntu:trusty as base-ults-old
FROM ubuntu:xenial as base-ults-previous
FROM ubuntu:bionic as base-ults-current

##################################################################
FROM base-alpine-current as alpine-current
# no shellcheck package on alpine
RUN apk add --no-cache make git bash ncurses
RUN apk add --no-cache file curl jq ffmpeg sqlite
WORKDIR /project
VOLUME /project
CMD /bin/sh

##################################################################
FROM base-ults-previous as ults-previous
RUN apt-get update && apt-get install -y make git shellcheck
# ffmpeg is too old, shellcheck is too old as well
RUN apt-get install -y file curl jq ffmpeg sqlite
WORKDIR /project
VOLUME /project
CMD /bin/sh

##################################################################
FROM base-ults-current as ults-current
RUN apt-get update && apt-get install -y make git shellcheck
RUN apt-get install -y file curl jq ffmpeg sqlite
WORKDIR /project
VOLUME /project
CMD /bin/sh

##################################################################
FROM base-deb-current as deb-current
RUN apt-get update && apt-get install -y make git shellcheck
RUN apt-get install -y file curl jq ffmpeg sqlite
WORKDIR /project
VOLUME /project
CMD /bin/sh

##################################################################
FROM base-deb-next as deb-next
RUN apt-get update && apt-get install -y make git shellcheck
RUN apt-get install -y file curl jq ffmpeg sqlite
WORKDIR /project
VOLUME /project
CMD /bin/sh

