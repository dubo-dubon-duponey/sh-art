# Extensions

Extensions provide advanced (or botched) functionality, or cover use cases that are too narrow to warrant inclusion in the main lib.
The API may not be well tested, or even be stable.

## http

### jwt

Decode a JWT token (requires `jq`).

```bash
dc-ext::jwt::read "$rawtoken"

# "the original rawtoken"
printf "%s\n" "$DC_JWT_TOKEN"
# header
printf "%s\n" "$DC_JWT_HEADER"
# payload
printf "%s\n" "$DC_JWT_PAYLOAD"
# access grant
printf "%s\n" "$DC_JWT_ACCESS"
```

### cache

Naive, simple, caching http client (requires `curl` and `sqlite`).

```bash
dc-ext::sqlite::init "yourdbsomewhere.db"
dc-ext::http-cache::init
dc-ext::http-cache::request "$url" "$method"
```

## sqlite

A generic SQLITE client (requires... `sqlite3`).

```bash
# Initialize
dc-ext::sqlite::init "yourdb.db"
# Ensure the table exist. Create it with description if it does not.
dc-ext::sqlite::ensure "table" "description"
dc-ext::sqlite::select "from table" "something" "where match"
dc-ext::sqlite::insert "into table" "fields" "values"
dc-ext::sqlite::delete "from table" "where match"
```
