# Core Library

The core library provides basic functionality, and should be fairly stable and decently tested.

## API

### argv

#### Description

Including the library will always parse flags (arguments prefixed by a single or double dash, with or without a value).

If a flag has been specified (with or without a value), `DC_ARGE_NAME` will be set (to `true`).

Values are available as `DC_ARGV_NAME` (where `NAME` is the capitalized, underscored form of the flag).

Flags must be passed before any other argument.

Examples:

`myscript -h`
```bash
[ "$DC_ARGE_H" ] && printf "%s\n" "-h has been passed"
[ ! "$DC_ARGV_H" ] && printf "%s\n" "with no value"
```
`myscript --something-special=foo`
```bash
[ "$DC_ARGE_SOMETHING_SPECIAL" ] && printf "%s\n" "-something-special has been passed"
[ "$DC_ARGV_SOMETHING_SPECIAL" == "foo" ] && printf "%s\n" "with value foo"
```

### colors

Color codes to be used with `tput` (eg: `$DC_COLOR_BLACK`).
This is mainly of interest internally, and you should rather use the `logging` or `output` modules.

### commander

High-level helper for command-line applications to initialize with decent defaults and arguments constraints.

Example implementation:

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


```bash
dc::commander::initialize
dc::commander::declare::flag myflag "^(foo|bar)$" "an optional flag that does foo or bar" optional
dc::commander::declare::arg 1 "^[0-9]+$" "some_arg" "first mandatory argument, that must be an integer"
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


### errors

Errors to be used as exit codes.

Used by core methods, and may be used by implementers as well if they fit.

Internal errors use the 200-299 range.

Custom errors defined by additional libraries should use the 100-199 range.

Custom errors defined by applications should use the 1-99 range.

Internal errors:
```bash
./bin/dc-libre env | grep "^ERROR" | sort

ERROR_ARGUMENT_INVALID=149
ERROR_ARGUMENT_MISSING=150
ERROR_ARGUMENT_TIMEOUT=151
ERROR_BINARY_UNKNOWN_ERROR=148
ERROR_CRYPTO_PEM_NO_SUCH_HEADER=159
ERROR_CRYPTO_SHASUM_FILE_ERROR=154
ERROR_CRYPTO_SHASUM_VERIFY_ERROR=158
ERROR_CRYPTO_SHASUM_WRONG_ALGORITHM=153
ERROR_CRYPTO_SSL_INVALID_KEY=155
ERROR_CRYPTO_SSL_WRONG_ARGUMENTS=157
ERROR_CRYPTO_SSL_WRONG_PASSWORD=156
ERROR_CURL_CONNECTION_FAILED=162
ERROR_CURL_DNS_FAILED=163
ERROR_ENCODING_CONVERSION_FAIL=160
ERROR_ENCODING_UNKNOWN=161
ERROR_FAILED=145
ERROR_FILESYSTEM=152
ERROR_GREP_NO_MATCH=147
ERROR_REQUIREMENT_MISSING=144
ERROR_UNSUPPORTED=146
```

### fs

Simple filesystem helpers

#### Methods

```bash
dc::fs::isfile [isWritable] [createIfMissing] || exit
dc::fs::isdir [isWritable] [createIfMissing] || exit
```

### http

A wrapper around curl.

#### Methods

```bash
# This will bypass the redacting mechanism, effectively logging credentials
# and other sensitive informations to stderr
# Typically wired-up with the MYCLI_LOG_AUTH environment variable.
dc::configure::http::leak

# This will bypass TLS verification errors (useful with self-signed certs, or if you don't care about security)
# Typically wired-up with the --insecure flag
dc::configure::http::insecure

# Dump the last received response headers to stderr at the warning level
dc::http::dump::headers

# Log the last received response body to stderr at the warning level (NO REDACTION HERE)
dc::http::dump::body

# URI encode "something"
dc::encoding::uriencode "something"

# Perform an http request (method defaults to HEAD if left unspecified)
dc::http::request URL [METHOD] [PAYLOAD] [request header] ... [request header]

# "dc::http::request" will set the following variables:
# - DC_HTTP_STATUS: 3 digit status code after redirects
# - DC_HTTP_REDIRECTED: final redirect location, if any
# - DC_HTTP_HEADERS: array of all the response headers keys
# - DC_HTTP_HEADER_XYZ: value of header XYZ (set for all headers listed in DC_HTTP_HEADERS)
# - DC_HTTP_BODY: temporary filename containing the raw body
```

### logger

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

#### Methods

```bash
# Set the log level to debug (all messages are logged)
dc::configure::logger::setlevel::debug

# Set the log level to info (all messages but debug are logged)
dc::configure::logger::setlevel::info

# Set the log level to warning (only warning and errors are logged)
dc::configure::logger::setlevel::warning

# Set the log level to error (only errors are logged)
dc::configure::logger::setlevel::error

# Set the log level to whatever level you pass it
dc::configure::logger::setlevel $level

# Mute any logging entirely. Users of your app will have to rely on exit codes for feedback.
# This is typically wired-up with the -s flag
dc::configure::logger::mute

# Log one or many debug message
dc::logger::debug $args...

# Log one or many info message
dc::logger::info $args...

# Log one or many warning message
dc::logger::warning $args...

# Log one or many error message
dc::logger::error $args...
```

### output

Simple helpers to output stuff to stdout.

### Methods

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

### Portable

Code for stuff that is not portable or hard to get right

#### Methods

```bash
dc::fs::mktemp "prefix"
dc::wrapped::base64d
```

### prompt

#### Methods
```bash
# Asks a question to the user and store the answer in $variablename
dc::prompt::question "message" variablename
# ... give the opportunity to the user to CTRL^C or press enter to continue
dc::prompt::confirm
# Ask for credentials. If no username is provided, will return without asking for a password
dc::prompt::credentials "message for username" varnameforusername "message for password" varnameforpassword
```

### System requirements

#### Methods

```bash
# binaryName is mandatory
dc::require binaryName || exit
# binaryName version 1.2 or above is required
dc::require binaryName --versionFlag 1.2 || exit
# DC_DEPENDENCIES_V_BINARYNAME will hold the version in case you need to inspect it

dc::require binaryName || dc::logger::warning "This program run best with binaryName, you should install it"

dc::require::platform::mac || exit # Require macos
dc::require::platform::linux || exit  # Require linux
dc::require::platform "$DC_PLATFORM_MAC" || exit 
dc::require::platform "$DC_PLATFORM_LINUX" || exit 
dc::require::platform "$YOUR_OWN_SHIT_MATCHING_UNAME" || exit 
```

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
