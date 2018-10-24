# sh-art

> just a piece of shcript

Developing marginally complex command line utilities using bash in a consistent manner presents challenges.

This project aims at providing a generic library facilitating that, primarily driven by personal needs.

Specifically, it takes care of argument parsing and validation, logging, http, string manipulation
and other commodities.

## TL;DR

On mac: `brew install sh_art`

You can then use one of the example binaries to get a taste (named `dc-*`).

Or start your own:

```
#!/usr/bin/env bash

. $(brew --prefix)/lib/dc-sh-art

readonly CLI_VERSION="0.0.1"
readonly CLI_LICENSE="MIT License"
readonly CLI_DESC="super top dupper awesome"

dc::commander::initialize
dc::commander::declare::flag myflag "^(foo|bar)$" "optional" "a flag that does foo or bar"
dc::commander::declare::arg 1 "[0-9]+" "" "first mandatory argument, that must be an integer"
dc::commander::boot
dc::require somebinary

if [ "$DC_ARGE_MYFLAG" ]; then
  dc::logger::info "Hey! You used --myflag, and the value was $DC_ARGV_MYFLAG. Did you try --help and --version as well?"
fi

dc::logger::debug "Now, let's query something"
dc::http::request "https://www.google.com" HEAD

dc::logger::warning "We got something!"
cat "$DC_HTTP_BODY"

# ... Now go do something useful below (like, looking at other cli for inspiration, or reading the docs)
```

## Requirements

Right now this is tested on macOS, Ubuntu 14.04, 16.04, 18.04, Debian stable and testing, and Alpine (and if that was not clear, 
it is meant to be used with bash).

Specific parts of the library have additional requirements (`jq`, `curl`, for example).

Some of the binaries may also declare additional requirements like `git`, `file`, `sqlite`, `shellcheck`, `make` or `ffmpeg`.

## Design principles

 * emphasize use of json for cli output ([you should really learn `jq`](https://stedolan.github.io/jq/manual/))
 * don't pollute stdout, use stderr for all logging
 * aim for correctness (re: shellcheck), but not true POSIX-ness (too boring)

## Moar

 * [explore some of the example clis](source/cli/README.md), as one of them may turn out to be useful
 * read about the [core library details](source/core/README.md)
 * or [extensions library details](source/extensions/README.md)
 
## Developping a new cli

A. Out of tree, see `TL;DR`.

B. In-tree, with builder / integration:

1. create a folder under cli named `mycli`, and add a shell script inside (look at others under cli for inspiration)
2. call `make build` to build
3. call `make lint` to enforce syntax checking
3. create integration tests under `tests/integration` and run `make test`

## Why... the... name?

 * it's a portementeau: "sh" (short for "shell") + "art" (short for "I like it"), which somewhat makes sense - what did you think it meant?
 * if it was powershell instead of bash, it would probably have been named `phart`, which doesn't really sound right

## TODO & research

 * continue work on performance for `dc::string`
 * finish porting remaining random scripts
 * https://gist.github.com/mathiasbynens/674099
 * fix imdb specs (array values)
 * movie-transform: add support for titles / year / director: https://multimedia.cx/eggs/supplying-ffmpeg-with-metadata/
 * explore using curl -w to build an HTTP perf/security testing tool
 * make a call on passing by reference or not for the string API: http://fvue.nl/wiki/Bash:_Passing_variables_by_reference

<!--
```
https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -euxo pipefail

# Exit immediately on fail
set -e
# Also exit on pipe failures
set -o pipefail
# Treat unset variables as an error
set -u
# Print all commands
set -x
# Trap errors
set -E

trap "echo EXIT trap fired!" EXIT
trap "echo SIGINT trap fired!" INT
trap "echo SIGTERM trap fired!" TERM
```
-->



