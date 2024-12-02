# Core Library

The core library provides bare minimum functionality, and should be fairly stable and decently tested.

## API

### dc::args

#### Description

Including the library will always parse flags (arguments prefixed by a single or double dash, with or without a value), and parameters.

Flag values are available as `DC_ARG_THE_NAME` (where `THE_NAME` is the capitalized, underscored form of the flag (`--the-name`)).

Flags must be passed before any other argument.

#### Examples

##### Flags

`myscript -h`
```bash
! dc::args::exist h || printf "%s\n" "-h has been passed"
[ "${DC_ARG_H:-}" ] || printf "%s\n" "with no value"
```
`myscript --something-special=foo`
```bash
! dc::args::exist something-special || {
    printf "%s\n" "--something-special has been passed"
    printf "%s\n" "with value: ${DC_ARG_SOMETHING_SPECIAL:-}"
}
```

##### Parameters

`myscript "arg 1" "arg 2"`
```bash
! dc::args::exist 1 || printf "%s\n" "first argument has been passed with value: ${DC_ARG_1:-}"
! dc::args::exist 2 || printf "%s\n" "second argument has been passed with value: ${DC_ARG_2:-}"
! dc::args::exist 3 || printf "%s\n" "third argument has been passed with value: ${DC_ARG_3:-}"
```

<!--
### colors

Color codes to be used with `tput` (eg: `$DC_COLOR_BLACK`).
This is mainly of interest internally, and you should rather use the `logging` or `output` modules.
-->

### dc::commander

#### Description

High-level helper for command-line applications to initialize with decent defaults and arguments constraints.

<!--
#### Methods

`dc::args::flag::validate something-special`

 * will require that `--something-special` is passed on the command-line, with or without a value
 * will exit with `$ERROR_ARGUMENT_MISSING` if this is not true

`dc::args::arg::validate 2`

 * will require that argument (non-flag) number two is set
 * will exit with `$ERROR_ARGUMENT_MISSING` if this is not true

`dc::args::flag::validate something-special REGEXP`

 * will require that `--something-special` is passed on the command-line, and its value matches the regexp
 * will exit with `$ERROR_ARGUMENT_INVALID` if this is not true

`dc::args::arg::validate 2 REGEXP`

 * will require that argument (non-flag) number two is set, and its value matches the regexp
 * will exit with `$ERROR_ARGUMENT_INVALID` if this is not true

-->

#### Examples

Example implementation:

```bash
dc::commander::initialize
dc::commander::declare::flag myflag "^(foo|bar)$" "an optional flag that does foo or bar" optional
dc::commander::declare::arg 1 "$DC_TYPE_INTEGER" "some_arg" "first mandatory argument, that must be an integer"
dc::commander::boot
```

By default, the following are always implemented:
```bash
mycli -h # show help
mycli --help # show help
mycli --version # show version
mycli -s # mute all logging
mycli --insecure # bypass TLS validation errors when doing http requests
```

... and the following environment variables are always processed (where `MYCLI` is the name of the embedding script):

```bash
# Can be set to "debug", "info", "warning" or "error" to control the level of logging.
MYCLI_LOG_LEVEL=debug
# When set to a non-null value, this below will also output authentication headers in the logs
# instead of redacting them out.
MYCLI_LOG_AUTH=true
```

#### Customization hooks:

The following environment variables may be set by the embedding script:

   * `CLI_NAME`: if not specified, will default to the name of the embedding script
   * `CLI_VERSION`: "0.0.1" by default
   * `CLI_LICENSE`: "MIT" by default
   * `CLI_DESC`: "A fancy piece of shcript" by default
   * `CLI_USAGE`: customize this if you don't like the output of the default help
   * `CLI_EXAMPLES`: allow to pass detailed examples as a paragraph of text
   * `DC_CLI_OPTS` (array): `( "my flag" "my arg description" )` - if you do not like the default help output

Additionally, the `dc::commander::initialize` may be called with arguments to control the name of the `MYCLI_LOG_LEVEL` and `MYCLI_LOG_AUTH` environment variables

For more flexibility, people can write their own `dc::commander::help` or `dc::commander::version` methods to further customize the output.

Or just take some inspiration from `dc::commander::initialize` and `dc::commander::boot` and write their own initialization routine...


### dc::error

#### Description

Errors to be used as exit codes.

Core errors use the 144-254 range.

Custom errors defined by applications and additional libraries should use the 3-125 range.

Internal errors:
```bash
./bin/dc-libre env | grep "^ERROR" | sort

# No error
ERROR_NO_ERROR=0

# Library errors
ERROR_ARGUMENT_INVALID=149
ERROR_ARGUMENT_MISSING=150
ERROR_ARGUMENT_TIMEOUT=151
ERROR_BINARY_UNKNOWN_ERROR=148
ERROR_CRYPTO_PEM_NO_SUCH_HEADER=160
ERROR_CRYPTO_SHASUM_FILE_ERROR=155
ERROR_CRYPTO_SHASUM_VERIFY_ERROR=159
ERROR_CRYPTO_SHASUM_WRONG_ALGORITHM=154
ERROR_CRYPTO_SSL_INVALID_KEY=156
ERROR_CRYPTO_SSL_WRONG_ARGUMENTS=158
ERROR_CRYPTO_SSL_WRONG_PASSWORD=157
ERROR_CURL_CONNECTION_FAILED=167
ERROR_CURL_DNS_FAILED=168
ERROR_DOCKER_MISSING_PLUGIN=164
ERROR_DOCKER_NO_SUCH_OBJECT=163
ERROR_DOCKER_WRONG_COMMAND=161
ERROR_DOCKER_WRONG_SYNTAX=162
ERROR_ENCODING_CONVERSION_FAIL=165
ERROR_ENCODING_UNKNOWN=166
ERROR_ERROR_DOCKER_BLOCKLAYER_STUCK=169
ERROR_FILESYSTEM=152
ERROR_GANDI_AUTHORIZATION=171
ERROR_GANDI_BROKEN=172
ERROR_GANDI_GENERIC=173
ERROR_GANDI_NETWORK=170
ERROR_GENERIC_FAILURE=146
ERROR_GREP_NO_MATCH=145
ERROR_LIMIT=153
ERROR_REQUIREMENT_MISSING=144

# System errors
ERROR_SYSTEM_COMMAND_NOT_EXECUTABLE=126
ERROR_SYSTEM_COMMAND_NOT_FOUND=127
ERROR_SYSTEM_EXIT_OUT_OF_RANGE=255
ERROR_SYSTEM_GENERIC_ERROR=1
ERROR_SYSTEM_INVALID_EXIT_ARGUMENT=128
ERROR_SYSTEM_SHELL_BUILTIN_MISUSE=2

# Signals
ERROR_SYSTEM_SIGABRT=134
ERROR_SYSTEM_SIGALRM=142
ERROR_SYSTEM_SIGHUP=129
ERROR_SYSTEM_SIGINT=130
ERROR_SYSTEM_SIGKILL=137
ERROR_SYSTEM_SIGQUIT=131
ERROR_SYSTEM_SIGTERM=143
ERROR_UNSUPPORTED=147
```

#### Examples

Error declaration

```
dc::error::register "SOMETHING"

env | grep "^ERROR_SOMETHING"
```

Error lookup

```
res=$(callingsomemethod foo) || exitcode=$?

dc::error::lookup "$exitcode"
```

Error detail

```
ls -lA /nonexistent || {
    dc::error::detail::set "ls failed on /nonexistent"
    exit "$ERROR_GENERIC_FAILURE"
}

# dc::error::detail::get # will retrieve the set error (useful in a trap for example)
```

### dc::fs

#### Description

Simple filesystem helpers

#### Examples

```bash
dc::fs::isfile somepath [isWritable] [createIfMissing]
dc::fs::isdir somepath [isWritable] [createIfMissing]
dc::fs::rm somepath
dc::fs::mktemp [prefix]
```

### dc::http

#### Description

A wrapper around curl.

#### Examples

```bash
# This will bypass the redacting mechanism, effectively logging credentials
# and other sensitive informations to stderr
# Typically wired-up with the MYCLI_LOG_AUTH environment variable.
dc::http::leak::set

# This will bypass TLS verification errors (useful with self-signed certs, or if you don't care about security)
# Typically wired-up with the --insecure flag
dc::http::insecure::set

# Log the last received response headers to stderr at the warning level
dc::http::dump::headers

# Log the last received response body to stderr at the warning level (NO REDACTION HERE)
dc::http::dump::body

# URI encode "something"
dc::encoding::uriencode "something"

# Perform an http request (method defaults to HEAD if left unspecified)
dc::http::request URL [METHOD] [PAYLOAD] [OUTPUT_FILE] [request header] ... [request header]

# "dc::http::request" will set the following variables:
# - DC_HTTP_STATUS: 3 digit status code after redirects
# - DC_HTTP_REDIRECTED: final redirect location, if any
# - DC_HTTP_HEADERS: array of all the response headers keys
# - DC_HTTP_HEADER_XYZ: value of header XYZ (set for all headers listed in DC_HTTP_HEADERS)
# - DC_HTTP_BODY: temporary filename containing the raw body
```

### dc::logger

#### Description
Provides logging.

All logs are written to stderr (which can then be easily redirected).

Any output is timestamped, and uses painfully bright colors matching the severity if the output is a term.

Currently, the logger does not support json output.

A typical log line looks like:

`[Mon Aug 27 18:37:47 PDT 2018] [WARNING] message foo bar baz`

The currently supported levels are:

 * `debug`: this level should only be used to log developer/debugging information
 * `info`: should be used only to convey meaningful workflow information that helps reading the logs
 * `warning`: denotes that there is an abnormal condition, recoverable error, or something that is worth notifying the user about
 * `error`: denotes an error that is non-recoverable, typically followed by exiting with a non-zero status

#### Examples

```bash
# Set the log level to debug (all messages are logged)
dc::logger::level::set::debug

# Set the log level to info (all messages but debug are logged)
dc::logger::level::set::info

# Set the log level to warning (only warning and errors are logged)
dc::logger::level::set::warning

# Set the log level to error (only errors are logged)
dc::logger::level::set::error

# Set the log level to whatever level you pass it
dc::logger::level::set $level

# Mute any logging entirely. Users of your app will have to rely on exit codes for feedback.
# This is typically wired-up with the -s flag
dc::logger::mute

# Log one or many debug message
dc::logger::debug $args...

# Log one or many info message
dc::logger::info $args...

# Log one or many warning message
dc::logger::warning $args...

# Log one or many error message
dc::logger::error $args...
```

### dc::output

#### Description

Simple helpers to output stuff to stdout.

#### Examples

```bash
dc::output::h1 "Title"
dc::output::h2 "Subtitle"
dc::output::emphasis "inline emphasized word"
dc::output::strong "inline SUPER emphasized word"
dc::output::bullet "bullet" "list" "of" "elements"
dc::output::strong "quoted sentence"
dc::output::text "inline text"
dc::output::rule "horizontal rule"
dc::output::break "line break"
# Output through jq for formatted, fancy visuals.
dc::output::json '{"foo": "bar"}'
```

### dc::prompt

#### Description



#### Examples
```bash
# Asks a question to the user and store the answer in $variablename
dc::prompt::question "message" variablename
# ... give the opportunity to the user to CTRL^C or press enter to continue
dc::prompt::confirm
# Ask for credentials. If no username is provided, will return without asking for a password
dc::prompt::credentials "message for username" varnameforusername "message for password" varnameforpassword
```

### dc::require

#### Examples

```bash
# binaryName is mandatory
dc::require binaryName
# binaryName version 1.2 or above is required
dc::require binaryName 1.2 --versionFlag
# DC_DEPENDENCIES_V_BINARYNAME will hold the version in case you need to inspect it

dc::require binaryName || dc::logger::warning "This program run best with binaryName, you should install it"

dc::require::platform::mac # Require macos
dc::require::platform::linux  # Require linux
dc::require::platform "$DC_PLATFORM_MAC" 
dc::require::platform "$DC_PLATFORM_LINUX" 
dc::require::platform "$YOUR_OWN_SHIT_MATCHING_UNAME"
```

### dc::trap

#### Description

All exit (errors, signals, explicit exit) are being trapped, and may be forwarded to "exit handlers".

This is convenient for:
 * providing shutdown/cleanup code
 * capture exceptions and provide detailed/localized information about the error condition outside of your main code
 * report errors to a third-party service

#### Examples

Two handlers are provided by default:
 * console handler (in `handler.sh`) that simply summarize the exception
 * busnag handler (in `extensions/bugsnag/reporter.sh`) that push exceptions to the BugSnag service (see `cli-ext/libre` for implementation)

Example implementation of your own handler:

```

myhandler(){
  local exit="$1"
  local detail="$2"
  local command="$3"
  local lineno="$4"

  dc::logger::error "[MYHANDLER] Exit code:       $exit"
  dc::logger::error "[MYHANDLER]      condition:  $(dc::error::lookup "$exit")"
  dc::logger::error "[MYHANDLER]      detail:     $detail"
  dc::logger::error "[MYHANDLER]      command:    $command"
  dc::logger::error "[MYHANDLER]      line:       $lineno"
}

dc::trap::register dc::error::handler
```

### Wrapped

#### Description

Code for stuff that is not portable or hard to get right

#### Examples

```
dc::wrapped::grep
dc::wrapped::base64d
```


#### Methods

```bash
dc::fs::mktemp "prefix"
dc::wrapped::base64d
```

<!--

### Version

A handful of variable holding sh-art version and build information.

```bash
DC_LIB_VERSION
DC_LIB_REVISION
DC_LIB_BUILD_DATE

DC_VERSION
DC_REVISION
DC_BUILD_DATE
```


### EXPERIMENTAL: incomplete implementation of the golang string API

#### Methods

TODO

-->
