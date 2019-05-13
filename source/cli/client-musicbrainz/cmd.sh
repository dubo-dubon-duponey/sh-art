#!/usr/bin/env bash

readonly CLI_VERSION="0.1.0"
readonly CLI_LICENSE="MIT License"
readonly CLI_DESC="query the Musicbrainz web-service for release info"

dc::commander::initialize
dc::commander::declare::flag raw "^$" "Do not process the result and return the info as-is from the webservice" optional
dc::commander::declare::arg 1 ".+" "identifier" "album identifier"
# Start commander
dc::commander::boot


readonly ua="DuboDubonDuponey/$CLI_VERSION"
# readonly QUERY="release-groups+media+discids+recordings+artist-credits+artists+aliases+labels+isrcs+collections+user-collections+artist-rels+release-rels+url-rels+recording-rels+place-rels+work-rels+recording-level-rels+work-level-rels"
readonly queryparams="release-groups+media+discids+recordings+artist-credits+artists+labels+isrcs+artist-rels+release-rels+url-rels+recording-rels+place-rels+work-rels+recording-level-rels+work-level-rels"
# Ignored for now: aliases+collections+user-collections

dc::http::request "https://musicbrainz.org/ws/2/release/$DC_PARGV_1?inc=$queryparams" "GET" "" "User-Agent: $ua" \
		"Host: musicbrainz.org:443" "Cache-Control: no-cache" "Pragma: no-cache" "Accept: application/json" "Accept-Language: en-US,*"

if [ "$DC_ARGE_RAW" ]; then
  cat "$DC_HTTP_BODY" | jq .
  exit
fi

cat "$DC_HTTP_BODY" | jq '{
  "RELEASE": {
    "ALBUM": .title,
    "TOTALDISCS": (.media | length | tostring),
    "BARCODE": .barcode,
    "ASIN": .asin,
    "DATE": .date,
    "RELEASECOUNTRY": .country,
    "RELEASESTATUS": .status,
    "ORIGINALDATE": ."release-group"."first-release-date",
    "RELEASETYPE": ."release-group"."primary-type",
    "VERSION": (.date + " " + .country + " " + .media[0].format + " " + .disambiguation + ": " + ([."label-info"[] | .label.name + " " + ."catalog-number"] | join(" | ")) + " | " + .barcode),
    "LABEL": [."label-info"[].label.name],
    "CATALOGNUMBER": [."label-info"[]."catalog-number"],
    "ALBUMARTIST": [."release-group"."artist-credit"[].artist.name],
    "ALBUMARTISTSORT": [."release-group"."artist-credit"[].artist."sort-name"],
    "SECONDARYTYPES": [."release-group"."secondary-types"[]],
    "MUSICBRAINZ_RELEASEGROUPID": ."release-group".id,
  },

  "RELATIONS": [
    .relations[] | {
      "TYPE": .type,
      "ENDED": .ended,
      "TARGET-TYPE": ."target-type",
      "ARTIST": .artist.name,
      "WORK": .work.title,
      "PLACE": .place.name,
      "PLACEAREA": .place.area.name,
      "ATTRIBUTES": .attributes,
      "URL": .url.resource,
    }
  ],

  "MEDIA": [
    .media[] | {
      "FORMAT": .format,
      "DISCNUMBER": .position,
      "TOTALTRACKS": ."track-count",

      "TRACKS": [
        .tracks[] | {
          "DATA": {
            "TITLE": .recording.title,
            "MUSICBRAINZ_RELEASETRACKID": .id,
            "MUSICBRAINZ_TRACKID": .recording.id,
            "ARTIST": [.recording."artist-credit"[].artist.name],
            "LENGTH": .length,
            "TRACKNUMBER": .number,
          },
          "IGNORED": {
            "POSITION": .position,
          },
          "RELATIONS": [
            .recording.relations[] | {
              "TYPE": .type,
              "ENDED": .ended,
              "TARGET-TYPE": ."target-type",
              "ARTIST": .artist.name,
              "WORK": .work.title,
              "PLACE": .place.name,
              "PLACEAREA": .place.area.name,
              "ATTRIBUTES": .attributes,
              "URL": .url.resource
            }
          ]
        }
      ]
    }
  ]
}'

# XXX DRUNK NOW
#          "WORK": (select(.work != null | .work)), <- need relationships as well
#          "THE REST": .


#          .work | (select(. != null) | "WORK": .work | {
#            "TITLE": .title,
#            "RELATIONS": [.relations[]]
#          },




           # + "<- has relations too, including composition, etc",


#      [.tracks[].recording.title],
#       "ARTIST": .tracks[].recording.artist-credit.artist.name

#       [.tracks[].recording.relations]

# release-groups+media+discids+recordings+
# artist-credits+artists+aliases+labels+isrcs+collections+user-collections+artist-rels+release-rels+url-rels+recording-rels+place-rels+work-rels+recording-level-rels+work-level-rels
