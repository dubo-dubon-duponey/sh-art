#!/usr/bin/env bash

readonly CLI_VERSION="0.1.0"
readonly CLI_LICENSE="MIT License"
readonly CLI_DESC="because I never remember how to use ffmpeg"

# Initialize
dc::commander::initialize
dc::commander::declare::flag destination ".+" optional "where to put the converted file - will default to the same directory if left unspecified"
dc::commander::declare::arg 1 ".+" "" "filename" "movie file to be checked / converted"
# Start commander
dc::commander::boot
# Requirements
dc::require jq
dc::require dc-movie-info
dc::require dc-movie-grify

dc::logger::info "Analyzing $DC_PARGV_1"

if ! data="$(dc-movie-info -s "$DC_PARGV_1")"; then
  dc::logger::error " > Media info analysis failed. Exiting."
  exit "$ERROR_FAILED"
fi

dc::logger::debug "$data"

#| jq -r -c '.tracks[] | select(.type == "audio")')"
#dc::logger::info "$(echo $data | jq -r -c '.tracks[] | select(.type == "subtitles")')"

# Basic info
CONTAINER=$(printf "%s" "$data" | jq -r .container)
FAST=$(printf "%s" "$data" | jq -r .fast)
DURATION=$(printf "%s" "$data" | jq -r .duration)

if [ "$DURATION" == "0" ]; then
  dc::logger::error " > No duration! Exiting."
  exit "$ERROR_FAILED"
fi

ALL_VIDEO_COUNT=$(printf "%s" "$data" | jq -r '.video | length')
REQUIRED_VIDEO_COUNT=$(printf "%s" "$data" | jq -r '[.video[] | select(.codec == "h264")] | length')

# "All audio" count
ALL_AUDIO_COUNT=$(printf "%s" "$data" | jq -r '.audio | length')

# "Audio that we need" count (DTS, AAC or AC-3)
REQUIRED_AUDIO=$(printf "%s" "$data" | jq '[.audio[] | select((.codec == "aac") or (.codec == "ac3") or (.codec == "dts"))]')
REQUIRED_AUDIO_COUNT=$(printf "%s" "$REQUIRED_AUDIO" | jq -r '. | length')
REQUIRED_AUDIO_SHOW=$(printf "%s" "$REQUIRED_AUDIO" | jq -r '.[] | (.id|tostring) + ": " + .codec + ", " + .language')

# Anything but DTS, AAC and AC3 should be removed
MUST_REMOVE_AUDIO=$(printf "%s" "$data" | jq '[.audio[] | select((.codec == "aac"|not) and (.codec == "ac3"|not) and (.codec == "dts"|not))]')
# MUST_REMOVE_AUDIO_COUNT=$(printf "%s" "$MUST_REMOVE_AUDIO" | jq -r '. | length')
# MUST_REMOVE_AUDIO_SHOW=$(printf "%s" "$MUST_REMOVE_AUDIO" | jq -r '.[] | (.id|tostring) + ": " + .codec + ", " + .language')

# Anything but DTS AAC and AC3 could be used as a source for conversion (because if we already have DTS AAC or AC3, we do not need to convert)
MAY_CONVERT_AUDIO=$(printf "%s" "$data" | jq '[.audio[] | select((.codec == "aac"|not) and (.codec == "ac3"|not) and (.codec == "dts"|not))]')
MAY_CONVERT_AUDIO_COUNT=$(printf "%s" "$MAY_CONVERT_AUDIO" | jq -r '. | length')
MAY_CONVERT_AUDIO_SHOW=$(printf "%s" "$MAY_CONVERT_AUDIO" | jq -r '.[] | (.id|tostring) + ": " + .codec + ", " + .language')

# Subs
ALL_SUBTITLES=$(printf "%s" "$data" | jq '.subtitles')
ALL_SUBTITLES_COUNT=$(printf "%s" "$ALL_SUBTITLES" | jq -r '. | length')

# Other stuff
OTHER_COUNT=$(printf "%s" "$data" | jq -r '.other | length')


#CONVERT_SUBTITLES=$(echo $data | jq '.subtitles[] | select((.codec == "SubRip/SRT") or (.codec == "SubStationAlpha"))')
#REMOVE_SUBTITLES=$(echo $data | jq '.subtitles[] | select(.codec == "VobSub")')

# Ensure video is kosher
dc::output::json "$data"

if [ "$ALL_VIDEO_COUNT" == "0" ]; then
  dc::logger::error " > No video? Exiting!"
  exit "$ERROR_FAILED"
fi

if [ "$ALL_VIDEO_COUNT" -ge 2 ]; then
  dc::logger::error " > More than one video stream? Exiting!"
  exit "$ERROR_FAILED"
fi

if [ "$REQUIRED_VIDEO_COUNT" == 0 ]; then
  dc::logger::error " > The video stream is not h264. Re-encoding would be the only option (unsupported for now). Exiting"
  exit "$ERROR_FAILED"
fi

# Comments on weird stuff...
if [ ! "$DURATION" ] || [ "$DURATION" -le 60 ]; then
  dc::logger::warning " > This is less than 60 seconds. Fishy."
fi

if [ "$ALL_AUDIO_COUNT" == 0 ]; then
  dc::logger::warning " > No audio. Weird."
fi

# Investigate audio
# Unusable audio streams will be removed anyway. The one case we want to cover here is multiple valid required audio streams
if [ "$REQUIRED_AUDIO_COUNT" -ge 2 ]; then
  dc::logger::warning " > Multi (AAC or AC3) audio here. This is usually just a waste of space."
  dc::prompt::question "Which one(s) do you want to remove (space separated ID list), out of '$REQUIRED_AUDIO_SHOW'? [leave empty for none] " REMOVE_AUDIO
fi

if [ "$ALL_SUBTITLES_COUNT" != 0 ]; then
  dc::logger::warning " > Subtitles in there. We will have to extract."
fi

if [ "$OTHER_COUNT" != 0 ]; then
  dc::logger::warning " > Other stuff in there!"
  dc::logger::debug "$(printf "%s" "$data" | jq '.other')"
fi

if [ "$CONTAINER" != "mov,mp4,m4a,3gp,3g2,mj2" ]; then
  dc::logger::warning " > This is not an MP4 container. We should re-containerize."
  CONTAIN=true
fi

if [ "$FAST" != "true" ]; then
  dc::logger::warning " > This is not optimized for the web. We should re-containerize."
  OPTIMIZE=true
fi

if [ "$REQUIRED_AUDIO_COUNT" == 0 ] && [ "$ALL_AUDIO_COUNT" != 0 ]; then
  dc::logger::warning " > There is no required (AAC, AC-3) audio stream in there. We shall create one."
  MUST_CONVERT_AUDIO="$MAY_CONVERT_AUDIO"
  if [ "$MAY_CONVERT_AUDIO_COUNT" -ge 2 ]; then
    dc::prompt::question " > There are more than one audio stream to convert from. \
    Since none of them are compatible, they will all be removed, and one of them will be converted to AAC.\
    Please pick the id of the one to be converted out of: $MAY_CONVERT_AUDIO_SHOW" MUST_CONVERT_AUDIO
    if [ ! "$MUST_CONVERT_AUDIO" ]; then
      dc::logger::error "Hey! We asked a question!"
      exit "$ERROR_FAILED"
    fi
    if [ "$(printf "%s" "$data" | jq -r --arg id "$MUST_CONVERT_AUDIO" '.audio | select(.id == $id) | length')" == 0 ]; then
      dc::logger::error "Wrrooooonnng!"
      exit "$ERROR_FAILED"
    fi
  else
    MUST_CONVERT_AUDIO=$(printf "%s" "$MAY_CONVERT_AUDIO" | jq -r -c '.[] | (.id | tostring)')
  fi
fi

# XXX subtitle collision here: sami microdvd

# XXX EXTRA CAREFUL HERE
# EXTRACT=( $(echo "$ALL_SUBTITLES" | jq -r -c '.[] | select(.codec == "dvd_subtitle"|not) | (.id|tostring) + ":" + (.id|tostring) + "." + .language + "." + .codec' | sed -E 's/subrip/srt/g' | sed -E 's/microdvd/sub/g' | sed -E 's/sami/smi/g' | sed -E 's/mov_text/srt/g') )
while read -r i; do
  EXTRACT[${#EXTRACT[@]}]="$i"
done < <(printf "%s" "$ALL_SUBTITLES" | jq -r -c '.[] | select(.codec == "dvd_subtitle"|not) | (.id|tostring) + ":" + (.id|tostring) + "." + .language + "." + .codec' \
  | sed -E 's/subrip/srt/g' | sed -E 's/microdvd/sub/g' | sed -E 's/sami/smi/g' | sed -E 's/mov_text/srt/g')



ALERT_SUBS=$(printf "%s" "$ALL_SUBTITLES" | jq -r -c '[.[] | select(.codec == "dvd_subtitle")] | length')
# EXTRACT=( $(echo $ALL_SUBTITLES | jq -r -c '.[] | (.id | tostring)') )

if [ "$ALERT_SUBS" -ge 1 ]; then
  dc::logger::error " > This file contains unprocessable subtitles that will get dropped. You should extract out of band with mkvextract tracks \"$DC_PARGV_1\" X:\"$DC_PARGV_1\""
  dc::logger::warning " > Press enter to continue (warning again: this sub WILL BE REMOVED)"
  dc::prompt::confirm
fi

# Manual answer to removal question
REMOVE=$REMOVE_AUDIO
# Must remove audio files
#ALSO_REMOVE=( $(echo "$MUST_REMOVE_AUDIO" | jq -r -c '.[] | (.id | tostring)') )
#if [ "${ALSO_REMOVE[*]}" ]; then
#  if [ "$REMOVE" ]; then
#    REMOVE="$REMOVE ${ALSO_REMOVE[*]}"
#  else
#    REMOVE="${ALSO_REMOVE[*]}"
#  fi
#fi

# ALSO_REMOVE=( $(echo "$ALL_SUBTITLES" | jq -r -c '.[] | (.id | tostring)') )
# XXX EXTRA CARE
ALSO_REMOVE=()
while read -r i; do
  ALSO_REMOVE[${#ALSO_REMOVE[@]}]="$i"
done < <(printf "%s" "$MUST_REMOVE_AUDIO" | jq -r -c '.[] | (.id | tostring)')
while read -r i; do
  ALSO_REMOVE[${#ALSO_REMOVE[@]}]="$i"
done < <(printf "%s" "$ALL_SUBTITLES" | jq -r -c '.[] | (.id | tostring)')


if [ "${ALSO_REMOVE[*]}" ]; then
  if [ "$REMOVE" ]; then
    REMOVE="$REMOVE ${ALSO_REMOVE[*]}"
  else
    REMOVE="${ALSO_REMOVE[*]}"
  fi
  # XXX
  # XXX dirty hack to still extract them
  # XXX
  #for i in ${ALSO_REMOVE[@]}; do
  #  echo mkvextract tracks "$DC_PARGV_1" $i:"$DC_PARGV_1.srt"
  #  echo $(mkvextract tracks "$DC_PARGV_1" $i:"$DC_PARGV_1.srt")
  #done
fi

CONVERT=$MUST_CONVERT_AUDIO

if [ "$CONTAIN" ] || [ "$OPTIMIZE" ] || [ "$CONVERT" ] || [ "$REMOVE" ] || [ "${EXTRACT[*]}" ]; then
  dc-movie-grify --destination="$DC_ARGV_DESTINATION" --convert="$CONVERT" --remove="$REMOVE" --extract="${EXTRACT[*]}" "$DC_PARGV_1"
  dc::logger::info " > Done"
  # dc::prompt::confirm
else
  dc::logger::info " > Nothing to do"
fi
