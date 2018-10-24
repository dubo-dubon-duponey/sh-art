# Developing sh-art

## Layout

### Source

 * `source/core`: base library source code
 * `source/extensions`: extensions modules
 * `source/cli`: regular CLIs depending on the core library
 * `source/cli-ext`: CLIs depending on the core library and extensions
 * `source/cli-tooling`: development CLIs (builder, etc)

### Tests

 * `tests/integration`: integration tests for all CLIs
 * `tests/unit`: unit test for the core library
 
## Makefile

### High-level targets

 * `make build`: build everything
 * `make lint`: source and commit validation
 * `make test`: run all tests
 * `make clean`: clean build artifacts
 
### Finer-grain targets

 * `make build-tooling`: build only the tooling
 * `make build-library`: build only the library (and extensions)
 * `make build-binaries`: build only the binaries
 * `make lint-signed`: commits validation
 * `make lint-code`: source validation
 * `make test-unit`: run unit tests
 * `make test-integration`: run integration tests

### Down and dirty

Individual binaries may be built / targeted as well, for example:

 * `make $(pwd)/bin/dc-tooling-lint` will build just the linter
 * `make integration/http` will run the integration tests just for the http cli
 * `make unit/assert.sh` will run just the assert unit tests

### Environment

 * `DC_PREFIX` controls the output directory (defaults to pwd)
 * `DC_NO_FANCY` if set, will disable color output

## Tools

`dc-tooling-build`, `dc-tooling-git`, `dc-tooling-lint` and `dc-tooling-test` are powering-up 
the corresponding make targets and may be used individually.

Look into the individual `--help`s for details.

## Creating a new cli

1. create a folder under `source/cli` (or `source/cli-ext` if extensions are needed) named `mycli`, and add a shell script inside (look at others under cli for inspiration)
2. call `make build` to build
3. call `make lint` to enforce syntax and commit checks
4. create integration tests under `tests/integration/mycli` and run `make test`

## Docker integration

`./dckr/do` is provided as a simple wrapper to run any command into one of the supported operating systems (with the project mounted).

You can simply call any of the make targets that way: `./dckr/do make lint`

By default, this will target Ubuntu 18.04.

To specify a different target, pass it as an environment variable: `TARGET=ults-previous ./dckr/do make lint`

Available targets are:

 * ults-previous: Ubuntu 16.04
 * ults-current: Ubuntu 18.04
 * deb-current: Debian stretch
 * deb-next: Debian buster
 * alpine-current: Alpine 3.8

## Travis

Currently test on macOS, Ubuntu 14.04 and 16.04.

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



