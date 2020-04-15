# sh-art

> just a piece of shcript

[![Build Status](https://travis-ci.org/dubo-dubon-duponey/sh-art.svg?branch=master)](https://travis-ci.org/dubo-dubon-duponey/sh-art)
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fdubo-dubon-duponey%2Fsh-art.svg?type=shield)](https://app.fossa.io/projects/git%2Bgithub.com%2Fdubo-dubon-duponey%2Fsh-art?ref=badge_shield)

A robust bash library (bash 3 to 5) meant to ease the development of complex command line shell script utilities.

Specifically, it takes care of argument parsing and validation, exception handling, logging, http, string manipulation, 
some crypto primitives, version inconsistencies fuckerisms, and other commodities, in a consistent fashion.

This is driven by personal needs.

## TL;DR

On mac: `brew install sh_art`

You can then use one of the example binaries to get a taste (named `dc-*`).

Or start your own `foobar` script:

```bash
#!/usr/bin/env bash
set -eu -o pipefail

. "$(brew --prefix)/lib/dc-sh-art"

# Information about your `foobar` script
readonly CLI_VERSION="0.0.1"
readonly CLI_LICENSE="MIT License"
readonly CLI_DESC="super top dupper awesome"

# Declare flags and arguments
dc::commander::initialize
dc::commander::declare::flag myflag "^(foo|bar)$" "a flag that does foo or bar" optional
dc::commander::declare::arg 1 "[0-9]+" "somearg" "first mandatory argument, that must be an integer"
dc::commander::boot

# State that you need the `find` binary
dc::require find

# Test if the optional flag `myflag` was set
if dc::args::exist myflag; then
  dc::logger::info "Hey! You used --myflag, and the value was ${DC_ARG_MYFLAG:-}. Did you try --help and --version as well?"
fi

# HEAD something over http
dc::logger::debug "Now, let's query something"
dc::http::request "https://www.google.com" HEAD

# Output the result
dc::logger::warning "We got something!"
dc::http::dump::body

# ... Now go do something useful (like, looking at other cli for inspiration, or reading the docs)
```

## Requirements

Right now this is tested on:
 * macOS 10.15
 * Ubuntu 14.04, 16.04, 18.04, rolling and next
 * Debian 8, 9, 10, testing, unstable
 * Alpine 3.8, 3.9, 3.10, 3.11 and edge

If that wasn't clear, this is meant to be used with bash.

Parts of the core library requires `jq`, `curl`, `shasum`, `openssl`.

Library extensions require `sqlite`.

Specific binaries (the `dc-tooling-*`) may also require additional binaries like `git`, `shellcheck`, `hadolint`, and `make`.

## Design principles

 * emphasize use of json for cli output ([you should really learn `jq`](https://stedolan.github.io/jq/manual/))
 * don't pollute stdout, use stderr for all logging
 * aim for correctness (eg: `shellcheck`), but not true POSIX-ness (too boring)

## Moar

 * [explore some of the example clis](source/cli/README.md), as one of them may turn out to be useful
 * read about the [core library details](source/core/README.md)
 * or [extensions library details](source/extensions/README.md)
 * or [developing sh-art](DEVELOP.md)
 
## Why the name?

 * it's a portementeau: "sh" (short for "shell") + "art" (short for "I like it"), which somewhat makes sense
 * if it was powershell instead of bash, it would probably have been named `phart`, which doesn't really sound right

## License

[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fdubo-dubon-duponey%2Fsh-art.svg?type=large)](https://app.fossa.io/projects/git%2Bgithub.com%2Fdubo-dubon-duponey%2Fsh-art?ref=badge_large)
