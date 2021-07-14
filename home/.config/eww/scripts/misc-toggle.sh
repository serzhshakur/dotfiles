#!/bin/bash

source $(dirname "$0")/commons.sh

if eww windows | grep -q '\*misc'; then
  eww close misc
else
  eww open misc -m "$MONITOR_IDX" -a "top center"
  source "$DIR"/wttr.sh -s
fi
