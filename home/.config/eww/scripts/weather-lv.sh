#!/bin/bash
# Gets weather from wttr.in

eww update loading="true"

area="Rīga"

declare -A icons=(
  [1101]="" [1102]="" [1103]="" [1104]="" [1105]=""
  [1201]="" [1202]="" [1203]="" [1204]="" [1205]="" [1205]="" [1206]="" [1207]="ﭽ" [1208]=""
  [1301]="" [1302]="" [1303]="" [1304]="" [1305]="" [1306]="" [1307]="" [1308]="" [1309]="" [1310]="" [1311]=""
  [1506]=""
  [2102]="" [2103]="" [2104]="" [2105]=""
)

get_value() {
  local json=$1
  local key=$2

  if [[ -n $json && -n $key ]]; then
    result=$(echo "$json" | jq -r --arg key "$key" '.[$key]' | xargs printf "%.0f\n")
    echo "$result"
  fi
}

get_start_time() {
  time=$(date +'%Y-%m-%d %H:00')
  if [[ $(date +'%-M') -gt 20 ]]; then
    time=$(date -d '+1 hour' +'%Y-%m-%d %H:00')
  fi
  echo "$time"
}

format_time() {
  local plus_hours=${1:-'0'} # possibility for adding hours
  local start_time

  start_time=$(get_start_time)
  new_time=$(date -d "$start_time $plus_hours hours" +'%Y%m%d%H00')
  echo "$new_time"
}

get_wind_dir_icon() {
  local wind_dir=$1
  dir_icon=""

  if [[ -n $wind_dir ]]; then
    if [[ $wind_dir -gt 340 || $wind_dir -lt 20 ]]; then
      dir_icon="↓"
    elif [[ $wind_dir -ge 20 && $wind_dir -lt 70 ]]; then
      dir_icon="↙"
    elif [[ $wind_dir -ge 70 && $wind_dir -lt 110 ]]; then
      dir_icon="←"
    elif [[ $wind_dir -ge 110 && $wind_dir -lt 160 ]]; then
      dir_icon="↖"
    elif [[ $wind_dir -ge 160 && $wind_dir -lt 200 ]]; then
      dir_icon="↑"
    elif [[ $wind_dir -ge 200 && $wind_dir -lt 250 ]]; then
      dir_icon="↗"
    elif [[ $wind_dir -ge 250 && $wind_dir -lt 290 ]]; then
      dir_icon="→"
    elif [[ $wind_dir -ge 290 && $wind_dir -lt 340 ]]; then
      dir_icon="↘"
    fi

  fi
  echo "$dir_icon"
}

get_for_hour() {
  local json=$1
  local time=$2

  if [[ -n $json && -n $time ]]; then
    result=$(echo "$json" | jq --arg key "$time" '.[] | select(.laiks==$key)')
    echo "$result"
  fi
}

response=$(
  curl -fsLG \
    --retry 3 --retry-connrefused \
    --connect-timeout 3 \
    --data-urlencode "nosaukums=$area" \
    "https://videscentrs.lvgmc.lv/data/weather_forecast_for_location_hourly" \
    2>/dev/null
)

time=$(format_time)
weather_raw=$(get_for_hour "$response" "$time")

temp="$(get_value "$weather_raw" 'temperatura')°C"
icon_code="$(get_value "$weather_raw" 'laika_apstaklu_ikona')"
icon=${icons[$icon_code]}
feel_temp="$(get_value "$weather_raw" 'sajutu_temperatura')°C"
wind=$(get_value "$weather_raw" 'veja_atrums')
wind_dir_degree=$(get_value "$weather_raw" 'veja_virziens')
wind_dir=$(get_wind_dir_icon "$wind_dir_degree")
clouds="$(get_value "$weather_raw" 'makoni')%"
precipitation="$(get_value "$weather_raw" 'nokrisni_1h') mm / $(get_value "$weather_raw" 'nokrisnu_varbutiba')%"

eww update weather_temp="$temp" &
eww update weather_icon="$icon" &
eww update weather_ftemp="$feel_temp" &
eww update weather_wind="$wind" &
eww update weather_clouds="$clouds" &
eww update weather_precipitation="$precipitation" &
eww update weather_wind_dir="$wind_dir" &
eww update weather_area="$area" &
eww update loading="false" &


for i in {1..3}; do
  start_time=$(get_start_time)
  new_time=$(date -u -d "$start_time $i hours" +'%H:%M')

  time_fmt=$(format_time $i)
  raw=$(get_for_hour "$response" "$time_fmt")

  temp_short="$(get_value "$raw" 'temperatura')°C"
  icon_code_short="$(get_value "$raw" 'laika_apstaklu_ikona')"
  icon_short=${icons[$icon_code_short]}

  eww update "temp_short_$i=$temp_short" &
  eww update "time_short_$i=$new_time" &
  eww update "icon_short_$i=$icon_short"
done
