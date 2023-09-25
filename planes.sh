#!/bin/bash

access_key=$(cat access_key)
date=$(date +'%Y-%m-%d')

date_secs=$(date +%s)
date_plus_hour_secs=$(($date_secs + 3600))

format='+"%Y-%m-%dT%H:%M"'
date_start=$(date -d @$date_secs $format | sed s/\"//g)
date_end=$(date -d @$date_plus_hour_secs $format | sed s/\"//g)


while getopts "a:" opt; do
    case $opt in
        a)
            curl -s --get -d access_key="$access_key" -d dep_icao="$OPTARG" http://api.aviationstack.com/v1/flights \
                | jq '.data' \
                | jq --arg s $date_start --arg e $date_end 'map(select(.departure.scheduled | . >= $s and . <= $e + "z"))' \
                | jq -r '["Flight", "ICAO", "Dep.", "Airport"], ["------", "----", "----", "-----------"], (.[] | [.flight.icao, .arrival.icao, .departure.scheduled, .arrival.airport]) | @tsv' \
                | sed -E s/[0-9]{4}-[0-9]{2}-[0-9]{2}T//g \
                | sed -E s/:[0-9]{2}.[0-9]{2}:[0-9]{2}//g \
                | awk 'NR<3{print $0;next}{print $0| "sort -k 3"}'
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            ;;
        :)
            echo "Option -$OPTARG requires an argument. See -h for more" >&2
            exit 1
            ;;
    esac
done

if [ $OPTIND -eq 1 ]; then echo "Usage: planes -a ICAO"; fi
