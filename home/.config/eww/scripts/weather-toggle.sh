#!/bin/bash

source $(dirname "$0")/commons.sh

if eww windows | grep -q '\*weather'; then
  eww close weather
else
  eww open weather -m "$MONITOR_IDX" -a "top center"
  source "$DIR"/weather-lv.sh
fi
