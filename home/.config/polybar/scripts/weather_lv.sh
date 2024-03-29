#!/bin/bash

# Either Font Awesome or Nerd font icons should be installed 
# to get icons correctly displayed

declare -A icons=(
  #
  # Font Awesome
  #
  [1101]=""
  [1102]=""
  [1103]=""
  [1104]=""
  [1105]=""
  [1201]=""
  [1202]=""
  [1203]=""
  [1204]=""
  [1205]=""
  [1205]=""
  [1206]=""
  [1207]=""
  [1208]=""
  [1301]=""
  [1302]=""
  [1303]=""
  [1304]=""
  [1305]=""
  [1306]=""
  [1307]=""
  [1308]=""
  [1309]=""
  [1310]=""
  [1311]=""
  [1506]=""
  [2102]=""
  #
  # Nerd Fonts
  #
  # [1101]=""
  # [1102]=""
  # [1103]=""
  # [1104]=""
  # [1105]=""
  # [1201]=""
  # [1202]=""
  # [1203]=""
  # [1204]=""
  # [1205]=""
  # [1205]=""
  # [1206]=""
  # [1207]="ﭽ"
  # [1208]=""
  # [1301]=""
  # [1302]=""
  # [1303]=""
  # [1304]=""
  # [1305]=""
  # [1306]=""
  # [1307]=""
  # [1308]=""
  # [1309]=""
  # [1310]=""
  # [1311]=""
  # [1506]=""
  # [2102]=""
)

get_time() {
  time=$(date +'%Y%m%d%H00')
  if [[ $(date +'%-M') -gt 20 ]]; then
    time=$(date -d '+1 hour' +'%Y%m%d%H00')
  fi
  echo "$time"
}

get_value() {
  local json=$1
  local key=$2

  if [[ -n $json && -n $key ]]; then
    result=$(echo "$json" | jq -r --arg key "$key" '.[$key]')
    echo "$result"
  fi
}

get_temp() {
  local json=$1

  if [[ -n $json ]]; then
    local icon_code=$(get_value "$response" "laika_apstaklu_ikona")
    icon_code=${icon_code%.0} # removing trailing ".0"
    local icon=${icons[$icon_code]}

    local temp=$(get_value "$response" "temperatura")

    # if temperature is outside (-1, 1) round it to whole number
    if [[ ! "$temp" =~ ^-?0\. ]]; then
      local temp=$(echo $temp | xargs printf "%.0f\n")
    fi

    local sign=''
    local first_char=$(echo $temp | cut -c 1)
    # prepend with '+' if temperature is positive
    if [[ $first_char != '-' && $temp != '0' ]]; then
      local sign='+'
    fi

    echo "$sign$temp°C $icon"
  fi
}

get_wind() {
  local json=$1

  if [[ -n $json ]]; then
    local wind_dir=$(get_value "$response" "veja_virziens" | xargs printf "%.0f\n")
    local wind_speed=$(get_value "$response" "veja_atrums" | xargs printf "%.0f\n")

    dir_icon=""
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

    echo "$dir_icon$wind_speed m/s"
  fi
}

time=$(get_time)

response=$(
  curl -fsLG \
    --retry 3 --retry-connrefused \
    --connect-timeout 3 \
    --data-urlencode "nosaukums=Rīga" \
    "https://videscentrs.lvgmc.lv/data/weather_forecast_for_location_hourly" \
    | jq --arg time "$time" '.[] | select(.laiks==$time)'
)

temp=$(get_temp "$response")
wind=$(get_wind "$response")

#echo "$temp $wind"
echo "$temp"
