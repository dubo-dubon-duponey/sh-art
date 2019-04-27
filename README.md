# sh-art

> just a piece of shcript

[![Build Status](https://travis-ci.org/dubo-dubon-duponey/sh-art.svg?branch=master)](https://travis-ci.org/dubo-dubon-duponey/sh-art)
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fdubo-dubon-duponey%2Fsh-art.svg?type=shield)](https://app.fossa.io/projects/git%2Bgithub.com%2Fdubo-dubon-duponey%2Fsh-art?ref=badge_shield)

Developing marginally complex command line utilities using bash in a consistent manner presents challenges.

This project aims at providing a generic library facilitating that, primarily driven by personal needs.

Specifically, it takes care of argument parsing and validation, logging, http, string manipulation
and other commodities in a consistent, elegant fashion.

## TL;DR

On mac: `brew install sh_art`

You can then use one of the example binaries to get a taste (named `dc-*`).

Or start your own `foobar` script:

```
#!/usr/bin/env bash

. "$(brew --prefix)/lib/dc-sh-art"

# Information about your `foobar` script
readonly CLI_VERSION="0.0.1"
readonly CLI_LICENSE="MIT License"
readonly CLI_DESC="super top dupper awesome"

# Declare flags and arguments
dc::commander::initialize
dc::commander::declare::flag myflag "^(foo|bar)$" optional "a flag that does foo or bar"
dc::commander::declare::arg 1 "[0-9]+" "" "somearg" "first mandatory argument, that must be an integer"
dc::commander::boot

# State that you need the `find` binary
dc::require find

# Test if the optional flag `myflag` was set
if [ "$DC_ARGE_MYFLAG" ]; then
  dc::logger::info "Hey! You used --myflag, and the value was $DC_ARGV_MYFLAG. Did you try --help and --version as well?"
fi

# HEAD something over http
dc::logger::debug "Now, let's query something"
dc::http::request "https://www.google.com" HEAD

# Output the result
dc::logger::warning "We got something!"
cat "$DC_HTTP_BODY"

# ... Now go do something useful below (like, looking at other cli for inspiration, or reading the docs)
```

## Requirements

Right now this is tested on macOS, Ubuntu 16.04 and 18.04, Debian stable and testing, and Alpine (and if that was not clear, 
it is meant to be used with bash).

Specific parts of the library have additional requirements (`jq`, `curl`, for example).

Specific binaries may also require additional binaries like `git`, `file`, `sqlite`, `shellcheck`, `make` or `ffmpeg`.

## Design principles

 * emphasize use of json for cli output ([you should really learn `jq`](https://stedolan.github.io/jq/manual/))
 * don't pollute stdout, use stderr for all logging
 * aim for correctness (eg: shellcheck), but not true POSIX-ness (too boring)

## Moar

 * [explore some of the example clis](source/cli/README.md), as one of them may turn out to be useful
 * read about the [core library details](source/core/README.md)
 * or [extensions library details](source/extensions/README.md)
 * or [developing sh-art](DEVELOP.md)
 
## Why... the... name?

 * it's a portementeau: "sh" (short for "shell") + "art" (short for "I like it"), which somewhat makes sense - what did you think it meant?
 * if it was powershell instead of bash, it would probably have been named `phart`, which doesn't really sound right

## License

[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fdubo-dubon-duponey%2Fsh-art.svg?type=large)](https://app.fossa.io/projects/git%2Bgithub.com%2Fdubo-dubon-duponey%2Fsh-art?ref=badge_large)
