#!/usr/bin/env bash

# Maybe replace by ffprobe...
relogic::mkvinfo(){
  local data=$(./debug media-info -s "$1")

  mkvquality=
  validatedDuration=

  if [ ! "$(echo $data | jq -rc '.duration')" ]; then
    return
  fi
  if [ "$(echo $data | jq -rc '.duration')" == 0 ]; then
    return
  fi
  if [ "$(echo $data | jq -rc '.video[0].width')" == "null" ]; then
    return
  fi

  # echo $data
  # echo "in"
  #dc::output::json "$data"
  mkvquality=$(echo $data | jq -rc '.video[] | "(" + (.id|tostring) + ")-" + .codec + "-" + (.width|tostring) + "x" + (.height|tostring)')
  mkvquality=$mkvquality-$(echo $data | jq -rc '.audio[] | "(" + (.id|tostring) + ")-" + .codec + "-" + .language')
  local duration=$(echo $data | jq -rc '(.size|tonumber) / (.duration|tonumber) / .video[0].width / .video[0].height')
  duration=$(echo "scale=2;$duration/1" | bc)
  mkvquality=$mkvquality-$duration

  local c=$(echo $data | jq -rc '.video[] | .codec')
  local w=$(echo $data | jq -rc '.video[] | (.width|tostring)')
  local h=$(echo $data | jq -rc '.video[] | (.height|tostring)')
  if [ $c == "h264" ]; then
    dc::logger::info "This movie is h264: $c"
    if [ $h -le 500 ] && [ $w -le 600 ]; then
      dc::logger::error "h264 BUT LD"
    elif [ $h -le 576 ] || [ $w -le 720 ]; then
      dc::logger::warning "h264 but MD"
    else
      dc::logger::info "And HD"
    fi
  else
    dc::logger::error "This movie is NOT h264: $c"
    if [ $h -le 500 ] && [ $w -le 600 ]; then
      dc::logger::error "AND LD"
    elif [ $h -le 576 ] || [ $w -le 720 ]; then
      dc::logger::warning "AND MD"
    else
      dc::logger::info "But it's HD"
    fi
  fi



  local checkDuration=$(echo $data | jq -rc '(.duration|tonumber) / 60 | floor')
  local i
  local delta=0
  local jitter=0
  for i in "${imdbLengths[@]}"; do
    #echo "> $i"
    #echo "> $checkDuration"
    delta=$(echo "scale=0;$checkDuration - ${i%%\(*}" | bc)
    jitter=$(echo "scale=0;($checkDuration - ${i%%\(*}) * 100 / ${i%%\(*}" | bc)

    if ( [ $delta -ge 2 ] || [ $delta -le -2 ]  ) && ( [ $jitter -ge 2 ] || [ $jitter -le -2 ] ); then
      dc::logger::warning "Moving on"
    else
      dc::logger::info "With local duration $checkDuration, found a decent match with version: $i"
      # XXX no simple way for now to store it in
      # validatedDuration=$checkDuration:$i
      break
    fi
  done

  if ( [ $delta -ge 2 ] || [ $delta -le -2 ]  ) && ( [ $jitter -ge 2 ] || [ $jitter -le -2 ] ); then
    dc::logger::error "Could not resolve movie duration $checkDuration to comp element: ${imdbLengths[@]}"
  fi

  dc::logger::debug "Estimated quality: [$mkvquality]"
}

__relogic::mkvinfo(){
  dc::logger::debug "mkvinfo \"$1\""

  local movieSize=$(ls -l "$1" | awk '{print $5}')

  local data=$(mkvmerge --identification-format json --identify "$1")
  local duration=$(echo $data | jq -r .container.properties.duration)
  # XXX DUGGGG
  if [ "$duration" != "null" ]; then
    duration=$(( $duration / 1000000 / 1000 ))
  fi

  if [ "$(echo $data | jq -r .tracks)" == "null" ]; then
    return
  fi
  local tracksn=( $(echo $data | jq -r .tracks[].id) ) #properties.number) )
  local trackscodec=( $(echo $data | jq -r .tracks[].properties.codec_id) )
  if [ "${trackscodec}" == "null" ]; then
    trackscodec=( $(echo $data | jq -r .tracks[].codec) )
  fi
  local trackstype=( $(echo $data | jq -r .tracks[].type) )
  local tracksdimension=( $(echo $data | jq -r .tracks[].properties.pixel_dimensions) )

  local width=
  local height=
  local qfactor=
  local i
  mkvquality=

  if [ ! "$tracksn" ]; then
    return;
  fi
  for i in $(seq 0 $(( ${#tracksn[@]}-1 )) ); do
    if [ "${trackscodec}" == "null" ] || [ "${trackstype[$i]}" != "video" ] && [ "${trackstype[$i]}" != "audio" ] || [ ! "${trackscodec[$i]}" ] ; then
      continue
    fi
    if [ "$mkvquality" ]; then
      mkvquality="${mkvquality}-"
    fi
    mkvquality=${mkvquality}\(${tracksn[$i]}\)-$(echo ${trackscodec[$i]} | tr "/" ":")
    if [ "${tracksdimension[$i]}" != "null" ]; then
      mkvquality=$mkvquality-${tracksdimension[$i]}
      height=${tracksdimension[$i]}
      width=${height%x*}
      height=${height#*x}
      dc::logger::debug "Width $width"
      dc::logger::debug "Height $height"
      dc::logger::debug "Duration $duration"
      dc::logger::debug "Movie size $movieSize"
      if [ $height -le 575 ] && [ $width -le 719 ]; then
        dc::logger::error "This movie is LD: $1"
      elif [ $height -le 700 ] && [ $width -le 1200 ]; then
        dc::logger::warning "This movie is MD: $1"
      else
        dc::logger::info "This movie is HD: $1"
      fi
      if [ "$duration" == "null" ]; then
        local altduration=$(ffprobe "$1" 2>&1 | grep "  Duration:" | sed -E 's/[^:]+[: ]+([0-9:]+).*/\1/')
        if [ "$altduration" ]; then
          duration=$(echo "${altduration%%:*} * 3600" | bc)
          altduration=${altduration#*:}
          duration=$(echo "$duration + ${altduration%%:*} * 60" | bc)
          duration=$(echo "$duration + ${altduration#*:}" | bc)
          dc::logger::debug "Ffprobe duration: $duration"
        fi
      fi
      if [ "$duration" != "null" ]; then
        qfactor=-$(echo "scale=2;$movieSize/$duration/$width/$height" | bc)
      fi
    fi
  done

  mkvquality=$mkvquality$qfactor

  dc::logger::debug "Estimated quality: [$mkvquality]"
}


___relogic::mkvinfo(){
  dc::logger::debug "mkvinfo \"$1\""

  local movieSize=$(ls -l "$1" | awk '{print $5}')

  mkvquality=$(mkvinfo "$1" | \
  while read i
  do
    key=${i%%:*}
    key=${key#*+ }
    value=${i#*: }

    if [ "$key" == "Track type" ]; then
      tracktype=$value
    fi
    if [ "$key" == "Cluster" ]; then
      total=$(( $total * $pixelwidth * $pixelheight ))
      abr=$(echo "scale=2;$movieSize/$total/60" | bc)
      echo -n "-$abr"
    fi
    if [ "$tracktype" == "subtitle" ]; then
      total=$(( $total * $pixelwidth * $pixelheight ))
      abr=$(echo "scale=2;$movieSize/$total/60" | bc)
      echo -n "-$abr"
      exit
    fi
    if [ "$key" == "Track number" ]; then
      tracknumber=${value%% *}
      if [ ! "$outthere" ]; then
        echo -n "($tracknumber)"
        outthere=true
      else
        echo -n "-($tracknumber)"
      fi
    fi
    if [ "$key" == "Codec ID" ]; then
      codecid=$(echo $value | tr "/" ":")
      echo -n "-$codecid"
    fi
    if [ "$key" == "Pixel width" ]; then
      pixelwidth=${value%% *}
      echo -n "-$pixelwidth"
    fi
    if [ "$key" == "Pixel height" ]; then
      pixelheight=${value%% *}
      echo -n "-$pixelheight"
    fi
    if [ "$key" == "Duration" ]; then
      hours=${value%%:*}
      rest=${value#*:}
      minutes=${rest%%:*}
      # total=$(( $hours * 60 + $minutes ))
      total=$(echo "$hours * 60 + $minutes" | bc)
    fi
  done)

  dc::logger::debug "Estimated quality: [$mkvquality]"
}
