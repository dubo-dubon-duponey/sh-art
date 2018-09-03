#!/usr/bin/env bash

relogic::mkvinfo(){
  local data
  data="$(./debug movie-info -s "$1")"
  shift

  mkvquality=

  if [ ! "$(echo "$data" | jq -rc '.duration')" ]; then
    return
  fi
  if [ "$(echo "$data" | jq -rc '.duration')" == 0 ]; then
    return
  fi
  if [ "$(echo "$data" | jq -rc '.video[0].width')" == "null" ]; then
    return
  fi

  local duration

  # echo $data
  # echo "in"
  #dc::output::json "$data"
  mkvquality="$(echo "$data" | jq -rc '.video[] | "(" + (.id|tostring) + ")-" + .codec + "-" + (.width|tostring) + "x" + (.height|tostring)')"
  mkvquality="$mkvquality-$(echo "$data" | jq -rc '.audio[] | "(" + (.id|tostring) + ")-" + .codec + "-" + .language')"
  duration="$(echo "$data" | jq -rc '(.size|tonumber) / (.duration|tonumber) / .video[0].width / .video[0].height')"
  duration="$(echo "scale=2;$duration/1" | bc)"
  mkvquality="$mkvquality-$duration"

  local c
  local w
  local h
  c="$(echo "$data" | jq -rc '.video[] | .codec')"
  w="$(echo "$data" | jq -rc '.video[] | (.width|tostring)')"
  h="$(echo "$data" | jq -rc '.video[] | (.height|tostring)')"
  if [ "$c" == "h264" ]; then
    if [ "$h" -le 500 ] && [ "$w" -le 600 ]; then
      dc::logger::error "This movie is h264 but LD: $1"
    elif [ "$h" -le 576 ] || [ "$w" -le 720 ]; then
      dc::logger::warning "This movie is h264 but MD: $1"
    else
      dc::logger::info "This movie is h264 and HD: $1"
    fi
  else
    if [ "$h" -le 500 ] && [ "$w" -le 600 ]; then
      dc::logger::error "This movie is NOT h264 ($c) and LD: $1"
    elif [ "$h" -le 576 ] || [ "$w" -le 720 ]; then
      dc::logger::warning "This movie is NOT h264 ($c) and MD: $1"
    else
      dc::logger::warning "This movie is NOT h264 ($c) but it's HD: $1"
    fi
  fi

  local checkDuration
  local i
  local delta=0
  local jitter=0
  local matching

  checkDuration="$(echo "$data" | jq -rc '(.duration|tonumber) / 60 | floor')"
  for i in "$@"; do
    #echo "> $i"
    #echo "> $checkDuration"
    delta=$(echo "scale=0;$checkDuration - ${i%% min*}" | bc)
    jitter=$(echo "scale=0;($checkDuration - ${i%% min*}) * 100 / ${i%% min*}" | bc)

    if { [ "$delta" -ge 2 ] || [ "$delta" -le -2 ]; } && { [ "$jitter" -ge 2 ] || [ "$jitter" -le -2 ]; }; then
      dc::logger::warning "Moving on"
    else
      matching="$i"
      # XXX no simple way for now to store it in
      # validatedDuration=$checkDuration:$i
      break
    fi
  done

  if [ "$matching" ]; then
    dc::logger::info "With local duration $checkDuration, found a decent match with version: $matching"
  else
    dc::logger::error "Could not resolve movie duration $checkDuration to available runtimes: $*}"
  fi

  dc::logger::debug "Estimated quality: [$mkvquality]"
}

