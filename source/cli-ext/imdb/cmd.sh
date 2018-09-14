#!/usr/bin/env bash

readonly CLI_VERSION="0.0.1"
readonly CLI_LICENSE="MIT License"
readonly CLI_DESC="imdb client, with caching"
readonly CLI_USAGE="[-s] [--insecure] [--image=(show|dump)] imdbID"

# Boot
dc::commander::init

# Arg 1 must be the digits section of a movie imdb id
dc::argv::arg::validate 1 "^tt[0-9]{7}$"
# Validate flag
if [ "$DC_ARGV_IMAGE" ]; then
  dc::argv::flag::validate image "^(?:show|dump)$"
fi

# Init sqlite
dc-ext::sqlite::init "$HOME/tmp/dc-client-imdb/cache.db"
dc-ext::sqlite::ensure "dchttp" "method TEXT, url TEXT, content BLOB, PRIMARY KEY(method, url)"

# Request the main page and get the body
dc-ext::http::request-cache "https://www.imdb.com/title/$1/" GET
body="$(printf "%s" "$DC_HTTP_BODY" | base64 -D | tr '\n' ' ')"

# Extract the shema.org section, then the original title and picture url
schema=$(printf "%s" "$body" | sed -E 's/.*<script type="application\/ld[+]json">([^<]+).*/\1/')
IMDB_ORIGINAL_TITLE=$(printf "%s" "$schema" | jq -rc .name)
IMDB_PICTURE=$(printf "%s" "$schema" | jq -rc .image)
[ "$IMDB_PICTURE" != "null" ] || IMDB_PICTURE=

# If we are being asked about the image, go for it, using fancy iterm extensions if they are here
if [ "$DC_ARGE_IMAGE" ]; then
  if [ ! "$IMDB_PICTURE" ]; then
    dc::logger::error "This movie does not come with a picture."
    exit "$ERROR_FAILED"
  fi
  dc-ext::http::request-cache "$IMDB_PICTURE" GET

  if [ ! "$DC_ARGV_IMAGE" ] || [ "$DC_ARGV_IMAGE" == "show" ]; then
    if [ "$TERM_PROGRAM" != "iTerm.app" ]; then
      dc::logger::error "You need iTerm2 to display the image"
      exit "$ERROR_FAILED"
    fi
    printf "\\033]1337;File=name=%s;inline=1;preserveAspectRatio=true;width=50:%s\\a" "$1" "$DC_HTTP_BODY"
    exit
  fi
  printf "%s" "$DC_HTTP_BODY" | base64 -D
  exit
fi


# Otherwise, move on

# Process the body to get the title, year and type
cleaned=$(printf "%s" "${body}" | sed -E "s/.*<meta property='og:title' ([^>]+).*/\\1/" | sed -E 's/.*content=\"([^\"]+)\".*/\1/')
IMDB_YEAR=$(printf "%s" "$cleaned" | sed -E "s/.*[(]([^)]*[0-9]{4}[–0-9]*)[)]/\\1/")
IMDB_TYPE=${IMDB_YEAR% *}
IMDB_YEAR=${IMDB_YEAR##* }
if [ "$IMDB_TYPE" == "$IMDB_YEAR" ]; then
  IMDB_TYPE="movie"
fi
IMDB_TITLE=$(printf "%s" "$cleaned" | sed -E "s/(.*)[[:space:]]+[(][^)]*[0-9]{4}[–0-9]*[)]/\\1/" | sed -E 's/&quot;/"/g')


# Now, fetch the technical specs
dc-ext::http::request-cache "https://www.imdb.com/title/$1/technical" GET

ALL_IMDB_KEYS=()
extractTechSpecs(){
  local body="$1"
  local sep
  local techline
  local key
  local value

  local technical=${body%%"</tbody>"*}
  technical=${technical#*"<tbody>"}
  while
      techline=${technical%%"</tr>"*}
      [ "$techline" != "$technical" ]
  do
    sep='<td class="label">'
    techline=${techline#*"$sep"}
    technical=${technical#*"</tr>"}
    key=${techline%%"</td>"*}
    value=${techline#*"<td>"}
    value=${value%%"</td>"*}
    key=$(dc::string::trimSpace key | dc::string::toUpper | tr -d '\n' | tr '[:space:]' '_')
#    key=$(echo "$result" | tr '[:lower:]' '[:upper:]' | tr -d '\n' | tr '[:space:]' '_')
    sep="<br>"

    # XXX broken: all values may potentially be arrays and that should be reflected in the output json
    if [ "$key" == "RUNTIME" ]; then
      IMDB_RUNTIME=()
      while IFS= read -r -d '' i; do
        IMDB_RUNTIME[${#IMDB_RUNTIME[@]}]=$(printf "%s" "$i" | tr -d '\n' | tr -d '\t' | sed -E 's/.*[ (]([0-9]+ min)[[:space:])]*(.*)?$/\1 \2/' | sed -E 's/[[:space:]]*$//')
      done < <( dc::string::split value sep )
      continue
    else
      value=$(printf "%s" "$value" | sed -E 's/<[^>]+>//g' | sed -E 's/[[:space:]]{2,}/ /g')
    fi
    read -r "IMDB_$key" < <(printf "%s" "$value")
    ALL_IMDB_KEYS[${#ALL_IMDB_KEYS[@]}]=$key
    dc::logger::debug "$key: $value"
  done
}

# Extract the specs
extractTechSpecs "$(printf "%s" "$DC_HTTP_BODY" | base64 -D | tr -d '\n')"

# Piss everything out in nice-ish json
heads=
for i in "${ALL_IMDB_KEYS[@]}"; do
  if [[ "TITLE YEAR RUNTIME ASPECT_RATIO" == *"$i"* ]]; then
    continue
  fi
  [ "$heads" ] && heads="$heads,"
  key=IMDB_$i
  heads=$heads"\"$i\": \"${!key}\""
done

result=$(dc::string::join IMDB_RUNTIME '", "')

output=$(printf "%s" "{$heads}" | jq --arg title "$IMDB_TITLE" \
  --arg year "$IMDB_YEAR" \
  --arg original "$IMDB_ORIGINAL_TITLE" \
  --arg picture "$IMDB_PICTURE" \
  --argjson runtime "[\"$result\"]" \
  --arg type "$IMDB_TYPE" \
  --arg id "$1" \
  --arg ratio "$IMDB_ASPECT_RATIO" -rc '{
  title: $title,
  original: $original,
  picture: $picture,
  year: $year,
  type: $type,
  runtime: $runtime,
  ratio: $ratio,
  id: $id,
  properties: .
}')

dc::output::json "$output"

# Call it a day
