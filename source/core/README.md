# Dubo Core Library

The core library provides basic functionality, and should be fairly stable and mildly to decently tested.

## API

### argv

#### Description
Including this file will parse flags (arguments prefixed by a single or double dash, with or without a value).

Flags values are available as DC_ARGV_NAME (where NAME is the capitalized, underscored form of the flag).

If a flag has been passed (with or without a value), DC_ARGE_NAME will be true.

Flags must be passed before any other argument.

Examples:
```
myscript -h

# [ "$DC_ARGE_H" == "true" ]
# [ ! "$DC_ARGV_H" ]

myscript --something_special=foo

# [ "$DC_ARGE_SOMETHING_SPECIAL" == "true" ]
# [ "$DC_ARGV_SOMETHING_SPECIAL" == "foo" ]
```

#### Methods

`dc::argv::flag::validate something-special`

 * will require that `--something-special` is passed on the command-line, with or without a value
 * will exit with `$ERROR_ARGUMENT_MISSING` if this is not true

`dc::argv::arg::validate 2`

 * will require that argument (non-flag) number two is set
 * will exit with `$ERROR_ARGUMENT_MISSING` if this is not true

`dc::argv::flag::validate something-special REGEXP`

 * will require that `--something-special` is passed on the command-line, and its value matches the regexp
 * will exit with `$ERROR_ARGUMENT_INVALID` if this is not true

`dc::argv::arg::validate 2 REGEXP`

 * will require that argument (non-flag) number two is set, and its value matches the regexp
 * will exit with `$ERROR_ARGUMENT_INVALID` if this is not true

### colors

Readable (eg: `$DC_COLOR_BLACK`) color codes to be used with `tput`.

### commander

High-level helper for command-line applications to initialize with decent defaults.

Implementers should simply call `dc::commander::init`.

By default, this will implement the following flags:
```
mycli -h # show help
mycli --help # show help
mycli --version # show version
mycli -s # mute all logging
mycli --insecure # bypass TLS validation errors when doing http requests
```

... and honor the following environment variables (where `MYCLI` is the name of the embedding script):

```
# Can be set to "debug", "info", "warning" or "error" to control the level of logging.
MYCLI_LOG_LEVEL=debug
# When set to a non-null value, this will also output authentication headers in the logs
# instead of redacting them out.
MYCLI_LOG_AUTH=true
```


#### Customization hooks:

The following environment variables may be defined by the embedding script:

   * `CLI_NAME`: if not specified, will default to the name of the embedding script
   * `CLI_VERSION`: "0.0.1" by default
   * `CLI_LICENSE`: "MIT" by default
   * `CLI_DESC`: "A fancy piece of shcript" by default
   * `CLI_USAGE`: "mycli [flags] argument" by default

Additionally, the `dc::commander::init` may be called with arguments to control the name of the `MYCLI_LOG_LEVEL` and `MYCLI_LOG_AUTH` environment variables

For more flexibility, people can write their own `dc::commander::help` or `dc::commander::version` methods to customize the output.

Or just take some inspiration from `dc::commander::init` and write their own initialization routine...


### errors

Errors to be used as exit codes.

These are used by core methods, and can be used by implementers as well if they fit.

They use the 200-299 range.

Custom errors defined by additional libraries should use the 100-199 range.

Custom errors defined by applications should use the 1-99 range.

```
# Network level error
ERROR_NETWORK=200

# Missing required argument
ERROR_ARGUMENT_MISSING=201

# Invalid argument
ERROR_ARGUMENT_INVALID=202

# Should be used to convey that a certain operation is not supported
ERROR_UNSUPPORTED=203

# Generic error to denote that the operation has failed
# More specific errors may be provided instead
ERROR_FAILED=204

# Expectations failed on a file (not readable, writable, doesn't exist, can't be created)
ERROR_FILESYSTEM=205
```

### fs

Simple filesystem helpers

#### Methods

```
dc::fs::isfile [isWritable] [createIfMissing]
dc::fs::isdir [isWritable] [createIfMissing]
```

### http

A wrapper around curl.

#### Methods

```
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
dc::http::uriencode "something"

# Perform an http request (method is HEAD if not specified)
dc::http::request URL [METHOD] [PAYLOAD] [request header] ... [request header]

# "dc::http::request" will set the following variables:
# - DC_HTTP_STATUS: 3 digit status code after redirects
# - DC_HTTP_REDIRECTED: final redirect location, if any
# - DC_HTTP_HEADERS: array of all the response headers keys
# - DC_HTTP_HEADER_XYZ: value of header XYZ (set for all headers listed in DC_HTTP_HEADERS)
# - DC_HTTP_BODY: temporary filename containing the raw body
```

### logger

Provides logging facility.

All logs are written to stderr, which can then be redirected to fit your mileage.

Any output is timestamped, and uses painfully bright colors matching the severity if the output is a term.

Currently, the logger does not support json output.

A typical log line looks like:

`[Mon Aug 27 18:37:47 PDT 2018] [WARNING] message foo bar baz`

The currently supported levels are:

 * `debug`: this level should only be used to log developer/debugging information
 * `info`: should be used only to convey meaningful workflow information that helps reading the logs
 * `warning`: denotes that there is an abnormal condition, recoverable error, or something that is worth noticing for the user
 * `error`: denotes an error that is non-recoverable, typically followed by exiting with a non-zero status

#### Methods

```
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

```
# Output through jq for formatted, fancy visuals.
dc::output::json "{}"
```

### prompt

#### Methods
```
# Asks a question to the user and store the answer in $variablename
dc::prompt::question "message" variablename
# ... give the opportunity to the user to CTRL^C or press enter to continue
dc::prompt::confirm
# Ask for credentials. If no username is provided, will return without asking for a password
dc::prompt::credentials "message for username" varnameforusername "message for password" varnameforpassword
```

### EXPERIMENTAL: partial implementation of the golang string API

#### Methods

...
