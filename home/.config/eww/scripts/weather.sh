#!/bin/bash
# Gets weather from wttr.in

eww update retry_status="..."

# Check connection
if ! ping -q -c 1 -W 1 wttr.in >/dev/null; then
  eww update whenconnected="false"
  eww update whennotconnected="true"
  eww update weather_lastcheck="$(date '+%I:%M %p')"
  eww update retry_status="Failed!"
  sleep 3
  eww update retry_status="Click to retry"
  exit 1
fi

source ~/.config/eww/eww-prefs

convert_kmh_to_ms() {
  local value=$1
  if [[ -n $value ]]; then
    result=$(echo $((value * 5 / 18)) | xargs printf "%.0f m/s\n")
    echo "$result"
  fi
}

get_wind_dir_icon() {
  local wind_dir_degrees=$1
  dir_icon=""

  if [[ -n $wind_dir_degrees ]]; then
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

weather_raw="$(curl wttr.in/${weather_location:-Riga}?format=j1 2>/dev/null)"

weather_current="$(echo "$weather_raw" | jq --raw-output '.current_condition | .[0]')"
weather_area="$(echo "$weather_raw" | jq --raw-output '.nearest_area | .[0]')"
weather_sun="$(echo "$weather_raw" | jq --raw-output '.weather | .[0].astronomy | .[0]')"

desc="$(echo "$weather_current" | jq --raw-output '.weatherDesc | .[0].value')"

temp="$(echo "$weather_current" | jq --raw-output '.temp_C')°C"
feel_temp="$(echo "$weather_current" | jq --raw-output '.FeelsLikeC')°C"

wind_kmh="$(echo "$weather_current" | jq --raw-output '.windspeedKmph')"
wind_dir_degree="$(echo "$weather_current" | jq --raw-output '.winddirDegree')"

wind=$(convert_kmh_to_ms "$wind_kmh")
wind_dir=$(get_wind_dir_icon "$wind_dir_degree")

area="$(echo "$weather_area" | jq --raw-output '.region | .[0].value')"
country="$(echo "$weather_area" | jq --raw-output '.country | .[0].value')"

sunrise="$(echo "$weather_sun" | jq --raw-output '.sunrise')"
sunset="$(echo "$weather_sun" | jq --raw-output '.sunset')"

shopt -s nocasematch
# Order matters for these
case "$desc" in
*snow*)
  case "$desc" in
  *heavy*)
    icon=""
    ;;
  *drifting*)
    icon=""
    ;;
  *)
    icon=""
    ;;
  esac
  ;;
*blizzard*)
  icon="流"
  ;;
*sleet*)
  icon=""
  ;;
*rain* | *drizzle* | *shower*)
  case "$desc" in
  *thunder*)
    icon=""
    ;;
  *patchy*)
    icon=""
    ;;
  *)
    icon=""
    ;;
  esac
  ;;
'Sunny')
  icon=""
  ;;
'Partly cloudy')
  icon=""
  ;;
'Very Cloudy' | 'Cloudy' | 'Overcast')
  icon=""
  ;;
'Clear')
  icon=""
  ;;
*fog* | *mist*)
  icon=""
  ;;
*fair*)
  icon=""
  ;;
*)
  icon=""
  ;;
esac

eww update weather_icon="$icon" &
eww update weather_desc="$desc" &
eww update weather_temp="$temp" &
eww update weather_ftemp="$feel_temp" &

eww update weather_wind="$wind" &
eww update weather_wind_dir="$wind_dir" &

eww update weather_area="$area" &
eww update weather_country="$country" &

eww update weather_sunrise="$sunrise" &
eww update weather_sunset="$sunset" &

eww update weather_lastcheck="$(date '+%I:%M %p')" &
wait
eww update whenconnected="true" &
eww update whennotconnected="false" &
