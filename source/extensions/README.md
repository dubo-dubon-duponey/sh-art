# Extensions

Extensions provide advanced (or botched) functionality, or cover use cases that are too narrow to warrant inclusion in the main lib.
The API may not be well tested, or even be stable.

## http

### jwt

Decode a JWT token (requires `jq`).

```
dc::jwt::read "$rawtoken"

DC_JWT_TOKEN="the original rawtoken"
DC_JWT_HEADER="the header"
DC_JWT_PAYLOAD="the payload"
DC_JWT_ACCESS="the access grant"
```

### cache

Naive, simple, caching http client (requires `curl` and `sqlite`).

```
dc-ext::sqlite::init "yourdbsomewhere.db"
dc-ext::http-cache::init
dc-ext::http-cache::request "$url" "$method"
```

## sqlite

A generic SQLITE client (requires... `sqlite3`).

```
# Initialize
dc-ext::sqlite::init "yourdb.db"
# Ensure the table exist. Create it with description if it does not.
dc-ext::sqlite::ensure "table" "description"
dc-ext::sqlite::select "from table" "something" "where match"
dc-ext::sqlite::insert "into table" "fields" "values"
dc-ext::sqlite::delete "from table" "where match"
```
