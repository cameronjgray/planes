#!/bin/bash

access_key=$(cat access_key)
date=$(date +'%Y-%m-%d')

date_secs=$(date +%s)
date_plus_hour_secs=$(($date_secs + 3600))

format='+"%Y-%m-%dT%H:%M"'
date_start=$(date -d @$date_secs $format | sed s/\"//g)
date_end=$(date -d @$date_plus_hour_secs $format | sed s/\"//g)

#curl -s --get -d access_key="$access_key" -d dep_icao=EGPH http://api.aviationstack.com/v1/flights \
#   | jq '.data' \
#   | jq --arg jq_date $date -r '["TEST", "ELSE"], ["----", "----"], (.[] | select(.flight_date | contains($jq_date)) | .arrival.airport, .arrival.icao) | @tsv'

cat flights \
    | jq --arg s $date_start --arg e $date_end 'map(select(.departure.scheduled | . >= $s and . <= $e + "z"))' \
    | jq --arg jq_date $date -r \
    '["Flight", "ICAO", "Airport"], ["------", "----", "-----------"], (.[] | [.flight.icao, .arrival.icao, .arrival.airport]) | @tsv'
