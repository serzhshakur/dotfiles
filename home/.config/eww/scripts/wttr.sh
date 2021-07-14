print_usage() {
  echo "FLAGS:"
  echo "  -a    update all"
  echo "  -s    update sunrise/sunset"
  echo "  -t    update temperature"
  exit 0
}

LOCATION=Riga
weather_raw="$(curl wttr.in/$LOCATION?format=j1 2>/dev/null)"

update_sunrise_sunset() {
  weather_sun="$(echo "$weather_raw" | jq --raw-output '.weather | .[0].astronomy | .[0]')"

  sunrise="$(echo "$weather_sun" | jq --raw-output '.sunrise' | xargs -0 date +'%H:%M' -d)"
  sunset="$(echo "$weather_sun" | jq --raw-output '.sunset' | xargs -0 date +'%H:%M' -d)"

  eww update sunrise="$sunrise" &
  eww update sunset="$sunset"
}

update_temp() {
  weather_current="$(echo "$weather_raw" | jq --raw-output '.current_condition | .[0]')"
  temp="$(echo "$weather_current" | jq --raw-output '.temp_C')°C"

  eww update weather_temp="$temp"
}

while getopts 'ast' flag; do
  case "${flag}" in
  a)
    update_sunrise_sunset
    update_temp
    ;;
  s) update_sunrise_sunset ;;
  t) update_temp ;;
  *)
    print_usage
    exit 1
    ;;
  esac
done
