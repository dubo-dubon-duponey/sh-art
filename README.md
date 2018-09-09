# sh-art

> just a piece of shcript (aka "dubo core" or "dc")

This project aims at providing a generic library facilitating the development
of marginally complex command-line shell scripts in a consistent manner, primarily
driven by personal needs.

Specifically, it takes care of argument parsing and validation, logging, http, and other
stuff.

Right now this is solely tested and used on macOS, using bash 3-something.

And you need `jq` and `curl` installed if you plan on doing anything useful.

## TL;DR

`brew install sh_art`

Then use one of the binaries (`dc-something`).

Or start your own:

```
#!/usr/bin/env bash

. $(brew --prefix)/lib/dc-sh-art

readonly CLI_VERSION="0.0.1"
readonly CLI_LICENSE="MIT License"
readonly CLI_DESC="super top dupper awesome"
readonly CLI_USAGE="[-s] [--insecure] [--myflag] param1 param2"

dc::commander::init

# Now do something useful below (like looking at other cli or reading the docs)
```

## Design principles

 * emphasize use of json ([you should really learn `jq`](https://stedolan.github.io/jq/manual/))
 * don't pollute stdout with random stuff
 * aim for correctness (shellcheck pass), but not true POSIX-ness (too boring)

## Moar

 * [explore some of the example clis](source/cli/README.md), as one of them may turn out to be useful
 * read about the [core library details](source/core/README.md)
 * or [extensions library details](source/extensions/README.md)
 
## Developping a new cli

A. Out of tree, create a shell script:

```
. PATH/TO/dc-library
dc::commander::init

# Now go do something useful (like looking at other cli or reading the docs)

```

B. In-tree, with builder / integration:

1. create a folder under cli named `mycli`, and add a shell script inside (look at others under cli for inspiration)
2. debug it live by running `./debug mycli [flags] [arguments]`
3. call `./build` to generate a standalone version under `bin/dc-mycli`

## Tooling

Includes a basic test framework.

1. call `./lint`
1. write tests under `tests/unit`
1. call `./unit`
1. write tests under `tests/integration/SOMETHING`
1. call `build`, then `./integration SOMETHING` or simply `./integration`

## Why... the... name?

 * it's a portementeau: "sh" (short for "shell") + "art" (short for "I like it"), which somewhat makes sense
 * what did you think it meant?
 * if it was powershell instead of bash, it would probably have been named `phart`, which doesn't really sound right

## TODO & research

 * use stdin with curl
 * continue work on performance for `dc::string`
 * continue integration tests for clis
 * finish porting remaining random scripts
 * https://gist.github.com/mathiasbynens/674099
 * consider moving to `make`
 * fix imdb specs (array values)
 * add travis (test bash4 as well)
 * implement requirement verification (jq, ffprobe, curl, etc)
 * finish regander
 * movie-transform: add support for titles / year / director: https://multimedia.cx/eggs/supplying-ffmpeg-with-metadata/
 * explore using curl -w to build an HTTP perf/security testing tool
 * finish moving to printf
 * make a call on passing by reference or not for the string API: http://fvue.nl/wiki/Bash:_Passing_variables_by_reference

```
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

```
Nastier tput effects
bold 	Start bold text
smul 	Start underlined text
rmul 	End underlined text
rev 	Start reverse video
blink 	Start blinking text
invis 	Start invisible text
smso 	Start "standout" mode
rmso 	End "standout" mode
sgr0 	Turn off all attributes
setaf <value> 	Set foreground color
setab <value> 	Set background color
```
