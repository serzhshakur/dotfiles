#!/bin/bash

export PATH=$HOME/.local/bin:$PATH

DIR=$(dirname "$0")
MONITOR=$(bspc query --names -M -m focused)
MONITORS=($(xrandr | grep -sw 'connected' | cut -d " " -f 1))
MONITOR_IDX=0

for i in "${!MONITORS[@]}"; do
  if [[ "${MONITORS[$i]}" == "$MONITOR" ]]; then
    MONITOR_IDX="${i}"
  fi
done

if eww windows | grep -q '\*weather'; then
  eww close weather
else
  eww open weather -m "$MONITOR_IDX" -a "top center"
  source "$DIR"/weather-lv.sh
fi
