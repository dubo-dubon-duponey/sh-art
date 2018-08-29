# sh-art

> just a piece of shcript - internally known as "dc" (short for "dubo (shell) core")

This project aims at providing a generic library facilitating the development
of marginally complex command-line shell scripts, primarily driven by personal needs.

Specifically, it takes care of argument parsing and validation, logging, http, and other
stuff.

Right now this is solely tested and used on macOS, using bash 3-something.

And you need `jq` and `curl` installed if you plan on doing anything useful.

## Design principles

 * emphasize use of json ([you should really learn `jq`](https://stedolan.github.io/jq/manual/))
 * don't pollute stdout with random stuff

## Moar

 * [explore some of the example clis](source/cli/README.md), as one of them may turn out to be useful
 * read about the [core library details](source/core/README.md)
 * or [extensions library details](source/extensions/README.md)
 
## Developping a new cli

A. Out of tree:

```
. PATH/TO/dc-library
dc::commander::init

# Now go do something useful

```

B. In-tree, with builder / integration:

1. create a folder under cli named `mycli`, and add a shell script inside (look at others under cli for inspiration)
2. debug it live by running `./debug mycli [flags] [arguments]`
3. call `./build` to generate a standalone version under `bin/dc-mycli`

## Tooling

Includes a basic test framework.

1. write tests under "tests"
2. call `./test`

## Why... the... name?

 * it's a portementeau: "sh" (short for "shell") + "art" (short for "I like it"), which somewhat makes sense
 * what did you think it meant?
 * if it was powershell instead of bash, it would probably have been named `phart`, which usually doesn't sound right

## TODO & research

 * use stdin with curl
 * work on performance for `dc::string`
 * write integration tests for cli
 * finish porting remaining random scripts
 * https://gist.github.com/mathiasbynens/674099
 * consider moving to make to build (right now, it's effing slow)
 * fix imdb specs (array values)
 * add travis (test bash4 as well)
 * evaluate posix-ness
 * implement requirement verification (jq, ffprobe, curl, etc)
 * finish regander
 * movie-transform: add support for titles / year / director: https://multimedia.cx/eggs/supplying-ffmpeg-with-metadata/
 * explore using curl -w to build an HTTP perf/security testing tool

### Research

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
